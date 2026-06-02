#!/usr/bin/env bash
set -e
VLCSTYLE="/home/portatil/vlc/modules/gui/qt/style/VLCStyle.qml"
QTCPP="/home/portatil/vlc/modules/gui/qt/qt.cpp"
FONT="Verdana"

cp -n "$VLCSTYLE" "$VLCSTYLE.bak" 2>/dev/null || true
cp -n "$QTCPP" "$QTCPP.bak" 2>/dev/null || true

sed -i \
 -e '/fontMetrics_xxsmall /s/dp(6, scale)/dp(8, scale)/' \
 -e '/fontMetrics_xsmall /s/dp(8, scale)/dp(10, scale)/' \
 -e '/fontMetrics_small /s/dp(10, scale)/dp(12, scale)/' \
 -e '/fontMetrics_normal /s/dp(12, scale)/dp(14, scale)/' \
 -e '/fontMetrics_large /s/dp(14, scale)/dp(16, scale)/' \
 -e '/fontMetrics_xlarge /s/dp(16, scale)/dp(18, scale)/' \
 -e '/fontMetrics_xxlarge /s/dp(20, scale)/dp(22, scale)/' \
 -e '/fontMetrics_xxxlarge /s/dp(24, scale)/dp(26, scale)/' \
 "$VLCSTYLE"

python3 - "$QTCPP" "$FONT" <<'PYEOF'
import sys, re
path, FONT = sys.argv[1], sys.argv[2]
with open(path, encoding='utf-8') as f: src=f.read()
if '#include <QFont>' not in src:
    src=src.replace('#include <QApplication>','#include <QApplication>\n#include <QFont>',1)
m=re.search(r'setFamily\(QStringLiteral\("([^"]*)"\)\)',src)
if m:
    src=src[:m.start(1)]+FONT+src[m.end(1):]
else:
    block='\n\n    {\n        QFont appFont = qApp->font();\n        appFont.setFamily(QStringLiteral("%s"));\n        qApp->setFont(appFont);\n    }'%FONT
    a2=re.search(r'QApplication\s+app\s*\([^)]*argc[^)]*\)\s*;',src)
    if a2: src=src[:a2.end()]+block+src[a2.end():]
    else: print(">> AVISO: no encontre 'QApplication app(...)'")
with open(path,'w',encoding='utf-8') as f: f.write(src)
print(">> fuente aplicada:", FONT)
PYEOF

echo ">> listo"
grep -n "setFamily" "$QTCPP"
