#!/usr/bin/env bash
set -e
QTDIR="/home/portatil/vlc/modules/gui/qt"
MISC="$QTDIR/pixmaps/misc"
QML="$QTDIR/maininterface/qml/NoMedialibHome.qml"
QRC="$QTDIR/assets.qrc"

if [ ! -f "$MISC/bg_claro.png" ] || [ ! -f "$MISC/bg_oscuro.png" ]; then
  echo ">> ERROR: faltan las imagenes. Copialas primero en: $MISC"
  exit 1
fi

cp -n "$QML" "$QML.bak" 2>/dev/null || true
cp -n "$QRC" "$QRC.bak" 2>/dev/null || true

python3 - "$QML" "$QRC" <<'PY'
import sys
qml, qrc = sys.argv[1], sys.argv[2]
with open(qml) as f: s=f.read()
if 'id: homeBackground' not in s:
    img='''    Image {
        id: homeBackground
        anchors.fill: parent
        source: theme.palette?.isDark ? "qrc:///misc/bg_oscuro.png"
                                       : "qrc:///misc/bg_claro.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

'''
    a='    ConeNButtons {\n        focus: true'
    if a in s:
        s=s.replace(a, img+a, 1); open(qml,'w').write(s); print(">> qml: fondo agregado")
    else:
        print(">> AVISO: no encontre el ancla ConeNButtons")
else:
    print(">> qml: ya tenia el fondo")
with open(qrc) as f: q=f.read()
if 'bg_claro.png' not in q:
    a='<file alias="cone.svg">pixmaps/misc/cone.svg</file>'
    q=q.replace(a, a+'\n        <file alias="bg_claro.png">pixmaps/misc/bg_claro.png</file>\n        <file alias="bg_oscuro.png">pixmaps/misc/bg_oscuro.png</file>',1)
    open(qrc,'w').write(q); print(">> qrc: imagenes registradas")
else:
    print(">> qrc: ya estaban registradas")
PY
echo ">> listo"
