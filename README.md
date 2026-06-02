# Proyecto VLC UI — Personalización de la interfaz de VLC Media Player

Proyecto académico (4.º semestre, Ingeniería de Software) que **modifica la interfaz de usuario de VLC Media Player** (rama `master`, VLC 4.0.0-dev, interfaz Qt 6 / QML), compilándolo desde el código fuente mediante compilación cruzada con WSL2 + mingw-w64.

> Este repositorio contiene **el trabajo del equipo** (documentación, scripts que aplican los cambios, imágenes y capturas). El código fuente completo de VLC **no** se incluye aquí: pertenece a VideoLAN (GPL) y se obtiene de `https://github.com/videolan/vlc`.

## Modificaciones realizadas

1. **Tipografía** — texto más grande (+2 dp en `VLCStyle.qml`) y familia **Verdana** (fijada como fuente de la aplicación en `qt.cpp`).
2. **Fondo adaptable al tema** — imagen de circuito en la **pantalla de inicio**, **detrás del cono y los botones**, con variante para **modo claro** (`bg_claro.png`) y **modo oscuro** (`bg_oscuro.png`), que cambia automáticamente según `theme.palette.isDark`.

## Estructura del repositorio

```
.
├── README.md
├── docs/
│   └── fuente_proyecto_vlc.md     # documento fuente detallado (qué, cómo y porqué)
├── scripts/
│   ├── tipografia.sh              # aplica la Modificación 1 sobre el código de VLC
│   └── fondo.sh                   # aplica la Modificación 2 sobre el código de VLC
├── imagenes/
│   ├── bg_claro.png               # fondo modo claro
│   └── bg_oscuro.png              # fondo modo oscuro
└── capturas/                      # evidencias (antes/después, compilación, GitHub)
```

## Cómo reproducir los cambios

1. Clonar VLC (`git clone https://github.com/videolan/vlc.git`) y compilarlo una vez con WSL2 + mingw-w64 (ver `docs/fuente_proyecto_vlc.md`, sección 5).
2. Copiar `imagenes/bg_claro.png` y `imagenes/bg_oscuro.png` a `modules/gui/qt/pixmaps/misc/`.
3. Ejecutar `scripts/tipografia.sh` y `scripts/fondo.sh` (ajustando la ruta del clon de VLC dentro de cada script).
4. Recompilar de forma incremental (`make`) y empaquetar (`make package-win-common`).
5. Ejecutar con `QML_DISABLE_DISK_CACHE=1` para ver el build actual a la primera.

## Archivos de VLC modificados

| Archivo | Cambio |
|---|---|
| `modules/gui/qt/style/VLCStyle.qml` | Tamaños de fuente +2 dp |
| `modules/gui/qt/qt.cpp` | Fuente de la app = Verdana |
| `modules/gui/qt/assets.qrc` | Registro de las dos imágenes |
| `modules/gui/qt/maininterface/qml/NoMedialibHome.qml` | Imagen de fondo según el tema |

## Equipo

Dylan Esteban Ricaurte Cuervo  
Brayan Stiven Garcia Camacho