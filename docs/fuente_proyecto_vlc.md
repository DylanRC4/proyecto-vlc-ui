# Documento Fuente — Proyecto de Modificación de VLC Media Player

> **Propósito de este documento:** servir como *fuente única y detallada* para generar, con apoyo de herramientas de IA (NotebookLM, etc.), la presentación de diapositivas y el informe escrito del proyecto. Contiene el qué, el cómo y el porqué de todo el trabajo: el software base, las modificaciones (antes/después), el flujo de trabajo técnico, la bitácora de la compilación, las herramientas utilizadas y el trabajo colaborativo con control de versiones.

---

## 0. Datos del proyecto (completar)

- **Nombre del proyecto:** [COMPLETAR — sugerencia: "VLC Reskin: rediseño de la interfaz de VLC Media Player"]
- **Asignatura / curso:** [COMPLETAR]
- **Docente / Decano:** [COMPLETAR]
- **Integrantes del grupo:** [COMPLETAR — nombre y rol de cada uno]
- **Semestre:** 4.º semestre de Ingeniería de Software
- **Fecha de presentación:** [COMPLETAR]
- **Repositorio del proyecto:** [COMPLETAR — enlace de GitHub]

---

## 1. Resumen ejecutivo

El proyecto consistió en **clonar, comprender y modificar la interfaz de usuario de VLC Media Player**, un reproductor multimedia de código abierto, real y de gran complejidad. El objetivo no fue solo cambiar código, sino demostrar el dominio de un **flujo de trabajo profesional completo**: análisis de un proyecto grande ajeno, modificación responsable de su interfaz, compilación desde el código fuente, control de versiones colaborativo y documentación.

El rediseño aplica una estética **oscura con acentos en tonos cobre/dorado**, incluyendo cambios de tipografía y un **fondo personalizado de circuito** en la pantalla de inicio. Más allá del resultado visual, el aprendizaje central estuvo en **resolver los retos reales de compilar un software de la escala de VLC**, lo que exigió diagnóstico, toma de decisiones de ingeniería y el uso de múltiples herramientas del ecosistema de desarrollo.

---

## 2. Objetivos

**Objetivo general:** Modificar la interfaz de usuario de VLC Media Player para mejorar/personalizar la experiencia visual, aplicando un flujo de trabajo de ingeniería de software íntegro y documentado.

**Objetivos específicos:**
1. Comprender la arquitectura de un proyecto de código abierto real y de gran tamaño.
2. Identificar y modificar los archivos correctos de la interfaz (tipografía, colores, fondo).
3. Compilar VLC desde el código fuente en un entorno Windows.
4. Aplicar control de versiones y trabajo colaborativo con Git y GitHub.
5. Documentar el proceso y comunicarlo mediante un informe y una presentación.
6. Incorporar herramientas modernas (incluida la IA) como aceleradores, de forma transparente.

---

## 3. El software base: VLC Media Player

**¿Qué es?** VLC es un reproductor multimedia libre y de código abierto desarrollado por la organización VideoLAN. Es multiplataforma (Windows, Linux, macOS, móviles) y reproduce prácticamente cualquier formato de audio y video.

**¿Por qué se eligió?**
- Es **software real y en producción**, usado por millones de personas (no un proyecto de juguete).
- Es **de código abierto**, lo que permite estudiarlo y modificarlo legalmente.
- Tiene una **arquitectura compleja y profesional**, ideal para aprender cómo se organiza y compila un sistema grande.

**Arquitectura relevante para el proyecto:**
- **Núcleo (`libvlccore`):** el corazón de VLC, escrito en C.
- **Módulos:** extensiones que añaden funcionalidad (códecs, salidas de audio/video, interfaces, etc.).
- **Interfaz gráfica Qt/QML:** la interfaz moderna de escritorio está construida con **Qt** y descrita en archivos **QML** (un lenguaje declarativo para interfaces). Aquí es donde se realizan las modificaciones de este proyecto.

**Sistema de compilación:** VLC no se compila como un proyecto pequeño. Requiere construir primero un conjunto de ~100 librerías de terceros llamadas **"contribs"** (entre ellas **FFmpeg** y **Qt**), y solo después se compilan el núcleo y los módulos. Esto hace que la compilación sea larga y sensible al entorno.

---

## 4. Las modificaciones (antes / después)

El rediseño se planteó en **fases**, tomando como referencia una estética oscura con acentos dorados/cobre.

### 4.1. Fase de tipografía — *Completada*

- **Archivo modificado:** `modules/gui/qt/style/VLCStyle.qml`
- **Cambio:** se actualizaron las **8 líneas de `fontMetrics`**, aumentando cada tamaño de fuente en **1 dp** y aplicando la familia tipográfica **"Segoe UI"**.
- **Efecto:** texto más legible y una apariencia más limpia y consistente con la estética buscada.

| | Antes | Después |
|---|---|---|
| **Familia tipográfica** | Por defecto del sistema | Segoe UI |
| **Tamaños de fuente** | Valores originales | +1 dp en cada métrica |

### 4.2. Fase de fondo personalizado — *En curso*

- **Idea:** reemplazar el fondo plano de la pantalla de inicio por una **imagen de circuito electrónico** (tonos cobre sobre fondo oscuro), coherente con la temática de ingeniería/tecnología.
- **Archivo objetivo:** `modules/gui/qt/maininterface/qml/MainDisplay.qml`, específicamente el `Rectangle { id: stackViewParent; color: theme.bg.primary }`, que es el fondo del área de contenido.
- **Comportamiento buscado:** el fondo se ve en la **pantalla de inicio** (donde aparece el cono de VLC) y **desaparece cuando se reproduce un video** (el video cubre la pantalla).
- **Decisión técnica:** se optó por la ruta "profesional" de **registrar la imagen como recurso** dentro de VLC (vía `assets.qrc` / sistema de build), para que quede empaquetada en el programa.

| | Antes | Después (objetivo) |
|---|---|---|
| **Fondo de inicio** | Color plano (`theme.bg.primary`) | Imagen de circuito cobre/oscuro |
| **Durante reproducción** | — | El video cubre el fondo (sin cambios) |

### 4.3. Fases planificadas

- **Iconos:** ajustar/reemplazar iconos acordes a la estética.
- **Panel lateral:** añadir un panel con miniaturas de video/audio.

---

## 5. Flujo de trabajo técnico (el "cómo")

> Esta sección es la más relevante desde el punto de vista de la ingeniería: documenta no solo el resultado, sino el **proceso de diagnóstico y las decisiones tomadas**.

### 5.1. Entorno de desarrollo

- **Editor:** Visual Studio Code.
- **Control de versiones:** Git (inicialmente vía GitHub Desktop).
- **Compiladores y shell Unix:** primero MSYS2; luego WSL2 (ver más abajo el porqué del cambio).

### 5.2. Entendiendo la compilación de VLC

Un hallazgo clave del proyecto fue comprender que **VLC no se puede compilar con Visual Studio / MSVC**. La documentación oficial (`doc/BUILD-win32.md`) establece que VLC para Windows se compila únicamente con **gcc o llvm sobre mingw-w64**, y que se requiere un **shell tipo Unix** (WSL, recomendado, o MSYS2). Esto reorientó el enfoque del equipo hacia las herramientas correctas.

### 5.3. Bitácora de la compilación (retos y soluciones)

Esta es la parte donde más se aprendió. La compilación de un proyecto de la escala de VLC rara vez funciona al primer intento; el valor está en **diagnosticar y resolver** cada obstáculo.

**Intento 1 — MSYS2 (compilación nativa en Windows):**
1. **Obstáculo:** al construir la herramienta *ninja*, su script de configuración intentó detectar el compilador de Microsoft (`cl`), porque el Python nativo de MINGW64 se comporta como Windows. Falló con `FileNotFoundError`.
   - **Diagnóstico:** desajuste entre el Python (que cree estar en Windows/MSVC) y el compilador real (mingw/gcc).
   - **Solución aplicada:** reconstruir ninja con el Python "posix" de MSYS2 y forzando `--platform mingw`, lo que evita la búsqueda de `cl`.
2. **Obstáculo:** con el Python posix, ninja intentó compilar una función exclusiva de Unix (`fork`/`pipe`) que el compilador de Windows no soporta.
   - **Solución:** `--platform mingw` desactiva esa función y usa gcc.
3. **Obstáculo (definitivo):** al entrar a los contribs, la compilación se detuvo con el error `main.mak:529: Recursive variable 'CMAKE' references itself`.
   - **Diagnóstico:** se localizó la causa exacta en el código fuente de VLC. La línea 528 de `contrib/src/main.mak`, **activa solo cuando la variable `MSYS_BUILD` está definida** (es decir, únicamente en la compilación nativa con MSYS2), redefine la variable `CMAKE` usándola a sí misma (`CMAKE = ... $(CMAKE)`). Como es una variable recursiva de *make*, esto genera una autorreferencia infinita que *make* rechaza. Es, en la práctica, un **defecto de VLC en su ruta de MSYS2**.

**Decisión de ingeniería — Pivote a WSL2:**

Ante el patrón de obstáculos (todos propios de MSYS2) y considerando que la parte más pesada (compilar Qt y FFmpeg) aún no había comenzado, el equipo tomó una **decisión de ingeniería fundamentada**: migrar a **WSL2 (Windows Subsystem for Linux)**, por tres razones:
1. Es el entorno **recomendado por la documentación oficial** de VLC.
2. El defecto del Makefile **no se dispara** en WSL, porque al compilar de forma cruzada desde Linux la variable `MSYS_BUILD` no se activa.
3. La compilación es **mucho más rápida** sobre el sistema de archivos nativo de Linux.

**Intento 2 — WSL2 (Ubuntu) — Solución adoptada:**
1. Activación de la **virtualización por hardware en la BIOS/UEFI** (requisito de WSL2).
2. Instalación de **Ubuntu** sobre WSL2.
3. Instalación de dependencias con `apt`, incluido el **toolchain mingw-w64 para x86_64**.
4. Clonado del repositorio **dentro del sistema de archivos de Linux** (no en el disco de Windows) para máxima velocidad de E/S.
5. Lanzamiento de la compilación cruzada (`build.sh -a x86_64`), que construye los contribs y produce un ejecutable de VLC para Windows.

### 5.4. Aprendizajes / criterio de ingeniería demostrado

- Saber **leer la documentación oficial** y ajustarse a ella (herramientas correctas: gcc/mingw, no MSVC).
- **Diagnosticar errores** hasta la causa raíz (incluido localizar un defecto en el propio código de VLC).
- Reconocer cuándo **insistir** y cuándo **cambiar de estrategia** (pivote a WSL2) en lugar de perseverar en un camino con rendimientos decrecientes.
- Entender conceptos de bajo nivel: finales de línea (LF vs CRLF), variables de *make* (recursivas vs simples), compilación cruzada, sistemas de build (autotools, meson, ninja).

---

## 6. Herramientas utilizadas

| Herramienta | Para qué se usó | Qué se aprendió |
|---|---|---|
| **Git** | Control de versiones | Clonado, configuración (`core.autocrlf`), commits |
| **GitHub** | Repositorio remoto y colaboración | Repos, colaboradores, ramas, pull requests |
| **GitHub Desktop** | Interfaz gráfica de Git | Operaciones básicas de Git de forma visual |
| **Visual Studio Code** | Edición de código | Navegación y edición de un proyecto grande |
| **Visual Studio 2022** | (Descartado para compilar) | Aprendizaje clave: VLC no compila con MSVC |
| **MSYS2** | Shell Unix en Windows (1.er intento) | Entornos (MINGW64/UCRT64), pacman, toolchains |
| **WSL2 + Ubuntu** | Entorno de compilación (solución) | Linux sobre Windows, apt, compilación cruzada |
| **mingw-w64 (gcc)** | Compilador para Windows | Compilación cruzada Linux → Windows |
| **meson / ninja / autotools** | Sistemas de build | Cómo se orquesta la compilación de VLC |
| **NotebookLM** | Generar presentación/informe | IA como acelerador de documentación |
| **IA asistente (Claude)** | Diagnóstico y guía paso a paso | IA como apoyo técnico transparente |

> **Nota sobre el uso de IA (integridad académica):** las herramientas de IA se utilizaron como **aceleradores y apoyo**, no como sustituto del aprendizaje. El equipo comprendió cada decisión técnica (por qué MSVC no sirve, por qué falló MSYS2, por qué WSL2 es mejor) y documentó el proceso de forma honesta y verificable.

---

## 7. Trabajo colaborativo y control de versiones (uso de GitHub)

El proyecto utiliza GitHub no solo como respaldo, sino como evidencia del **trabajo en equipo** de cada integrante.

- **Repositorio del proyecto** con todos los compañeros agregados como **colaboradores**.
- **Estrategia de ramas (branching):**
  - `main`: versión estable/documentada.
  - Una rama por fase o tarea (p. ej. `feature/tipografia`, `feature/fondo-circuito`), para trabajar sin pisarse.
- **Convención de mensajes de commit** (claros y descriptivos), por ejemplo siguiendo *Conventional Commits*:
  - `feat: aplicar fuente Segoe UI y +1dp en VLCStyle.qml`
  - `feat: agregar fondo de circuito en MainDisplay.qml`
  - `docs: redactar bitácora de compilación`
  - `fix: corregir ruta de recurso de la imagen`
- **Flujo de trabajo:** crear rama → hacer cambios → `commit` → `push` → abrir **Pull Request** → revisión entre compañeros → `merge` a `main`.
- **Evidencia individual:** el historial de commits y los Pull Requests muestran **qué aportó cada integrante**, lo cual es ideal para una evaluación que valora el trabajo íntegro y colaborativo.

---

## 8. Despliegue y ejecución del VLC modificado

- La compilación cruzada desde WSL2 produce un **`vlc.exe` para Windows** junto con sus librerías y módulos.
- Para obtener una versión ejecutable y autocontenida, VLC ofrece empaquetar el resultado (objetivo `package-win-common`), generando una carpeta con el ejecutable y las DLL en su lugar.
- Los archivos generados en WSL son accesibles desde Windows a través de la ruta `\\wsl$\Ubuntu\...`, o copiándolos al disco de Windows.
- **Demostración en vivo:** abrir el VLC compilado y mostrar la pantalla de inicio con el fondo de circuito y la tipografía modificada, comparándola con un VLC oficial.

---

## 9. Resultados y evidencias (completar)

- [ ] Captura de pantalla del **VLC original** (antes).
- [ ] Captura de pantalla del **VLC modificado** (después): tipografía y fondo.
- [ ] Captura del **historial de commits / Pull Requests** en GitHub.
- [ ] Captura de la **compilación exitosa** (terminal de WSL).
- [ ] (Opcional) Breve video de la demostración en vivo.

---

## 10. Conclusiones

- Se logró modificar la interfaz de un software real y complejo (VLC), aplicando un flujo de trabajo profesional de principio a fin.
- El mayor aprendizaje no fue solo escribir QML, sino **compilar un proyecto grande**, **diagnosticar errores reales** y **tomar decisiones de ingeniería fundamentadas** (el pivote de MSYS2 a WSL2).
- El equipo ejercitó el **trabajo colaborativo con Git/GitHub** y el uso responsable de herramientas modernas, incluida la IA.
- El proyecto refleja el perfil de un ingeniero íntegro: que entiende el porqué de sus decisiones, domina sus herramientas y comunica su trabajo.

---

## 11. Apéndice — Glosario rápido

- **Contribs:** conjunto de librerías de terceros que VLC necesita y compila antes que su propio código.
- **Compilación cruzada:** compilar en un sistema (Linux) un programa destinado a otro (Windows).
- **QML:** lenguaje declarativo de Qt para describir interfaces de usuario.
- **mingw-w64:** toolchain de compiladores (gcc) que produce ejecutables para Windows.
- **WSL2:** Subsistema de Windows para Linux; permite ejecutar Linux dentro de Windows.
- **CRLF vs LF:** finales de línea de Windows (CRLF) vs Unix (LF); mezclarlos rompe los scripts de compilación.
- **Pull Request (PR):** propuesta de incorporar cambios de una rama a otra, con revisión previa.
