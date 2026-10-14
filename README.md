# Build123d-Portable-Installer

## Component setup

The installer uses a native NSIS components tree with descriptions and three choices:

- **Build123d (recommended):** WinPython, Build123d and its required Python
  packages, portable VS Code, Python extension, OCP CAD Viewer, and Jupyter.
- **Portable VS Code:** the editor without Python or extensions.
- **Custom:** select individual components, including Cadquery, additional
  extensions, Portable Git, Fossil, USB helpers, and code snippets.

Required components are selected automatically and locked while a selected
component needs them. OCP CAD Viewer requires the Build123d packages, WinPython,
the Python extension, and VS Code. Cadquery and Build123d packages require
WinPython. Extensions, version control integration, and portable helpers require
VS Code. Deselect dependents first to unlock their prerequisites. At least
WinPython or VS Code must be selected.

After choosing components and a destination, the Options page provides a desktop
shortcut, workspace preferences, download cleanup (enabled by default), and an
advanced settings checkbox. Workspace preferences enable automatic opening of
untrusted files and editor line highlighting; existing `settings.json` files are
preserved. Advanced settings let you change download URLs and extension
Marketplace IDs for selected components. Edits and options survive Back/Next
navigation. Close running VS Code windows before installing extensions.

Component disk requirements include estimated download/extraction headroom.
Actual requirements vary with the versions selected in advanced settings.
Use separate installation directories for different WinPython versions.
Downloads, extraction, pip, and extension failures stop installation before later
components run. Cleanup runs after successful installation.

## Source layout and validation

Run **Actions → build-nsis → Run workflow** to build an installer and create a
draft release containing `PortableBuild123dSetup.exe`. Pushing a `v*` tag also
creates a draft release for that tag. Manual builds use `build-<run-id>` as the
release tag; rerunning a build replaces the asset only while its release remains
a draft. Pull requests produce Actions artifacts only. Review and publish drafts
from the repository's Releases page when ready.

The native wizard is enlarged by 40% in both dimensions to give the components
tree more room. `tools/enlarge_ui.py` generates its dialog resources from the
installed NSIS UI during compilation; building requires Python 3 on Windows.
The component tree and preset selector have twice their enlarged width.
The component description spans the page above the installation-type selector.
The wizard has an additional 20% height assigned to the component tree, plus
another approximately 5% of tree height (`TREE_EXTRA_HEIGHT` in the generator).
All component groups are expanded initially.

`Build123dPortableSetup.nsi` declares the wizard and assembles these modules:

| File | Responsibility |
| --- | --- |
| `Installer/Components.nsh` | Ordered installation sections, groups, presets, size estimates, descriptions |
| `Installer/Selection.nsh` | Dependencies, prerequisite locks, preset application, selection validation |
| `Installer/Pages.nsh` | Options and advanced settings pages |
| `Installer/Operations.nsh` | Downloads, extraction, packages, extensions, launchers, finalization |
| `Installer/Defaults.nsh` | Initial URLs, Marketplace IDs, and options |
| `Installer/Variables.nsh` | Shared runtime variables |
| `Languages/*.nsh` | Translated labels, descriptions, and messages |

Build with Unicode NSIS and the inetc, Nsis7z, and nsisunz x86-unicode plugins,
as configured in `.github/workflows/build-nsis.yml`. The workflow also runs:

```powershell
python tests/run_checks.py "C:\Program Files (x86)\NSIS\makensis.exe"
```

The checks execute the real NSIS selection code, validate both translations,
generate and relocate launchers to paths with spaces, and run pip/extension
commands against local mocks. They preserve existing settings and check cleanup.
They download no application packages. Artifacts are written to `.build-tools/`.
Full downloads and actual third-party installations still require a Windows
installation smoke test.

## Installer languages

The installer supports English and German. A language picker appears before the
welcome page, with the Windows language selected when supported and English as
the fallback. The selection applies to the standard wizard pages, custom options,
installation messages, and error dialogs. Language selection does not write to
the registry. Downloaded software and its own output use their own language settings.

Custom translations are stored in `Languages/English.nsh` and
`Languages/German.nsh` as UTF-8 files. To add a language:

1. Copy `Languages/English.nsh` to a new language file and translate each text,
   keeping the `LangString` names unchanged.
2. Replace `${LANG_ENGLISH}` with the NSIS language constant for that language.
3. Add its `!insertmacro MUI_LANGUAGE "LanguageName"` beside the existing language
   declarations in `Build123dPortableSetup.nsi`, before `MUI_RESERVEFILE_LANGDLL`.
4. Include the new translation file beside the existing language includes.
5. Preserve runtime variables such as `$0` and `$VsCodeINSTDIR`, line breaks
   (`$\r$\n`), and the `%s` extraction placeholder. Escape embedded double quotes
   as `$\"`.
6. Compile using the existing NSIS build workflow and check the custom pages for
   clipped labels in the new language.

## General Information and first start
This is a NSIS based installer for a portable Windows IDE environment for build123d, python and VsCode.

Build123d-Portable-Installer is a web installer. It allows you to download the necessary software and to
install it. During the setup some files are modified  to allow for a fully portable setup.

Fully portable means that you can install and delete the software setup without any registry changes or
other dependencies. You can copy the installation to any hard drive you like. You also can use it on your 
USB thumb drive - just copy your installation there.
The generated `VsCode.cmd` launcher uses paths relative to its own directory,
so moving the installation does not require rewriting paths. The optional
`ThumbdriveAdjust.cmd` helper starts that launcher from the environment root.
For this reason you also can uncheck the python part and use the installer as
a setup for a portable Visual Studio Code setup (In that case use VsCode.cmd to start you VsCode session).

After installation, start VS Code using `VsCode.cmd`:

- With WinPython: `[Installdirectory]\[PythonVersionPath]\t\vscode\VsCode.cmd`
- Editor only: `[Installdirectory]\VsCode.cmd`

The launcher loads the WinPython environment when installed and adds selected
Git/Fossil tools to the session PATH. No machine-wide PATH changes are made.

The downloaded files can be found under:<br>
<b>[Installdirectory]\\Downloads</b>

The current preset is that the installation files are removed but you can change that.

Remember to use:

<i>from build123d import *</i></br>
<i>from ocp_vscode import *</i></br>

as header for your python file to enable build123d and OCP Cad Viewer.

<b>After starting VsCode the first time and trying to run your first build123d project you might encounter a problem that the viewer
is not working correctly. To avoid this: 
1) Create/Load a file with the python extension ".py".
2) Close the (empty) OCP Cad Viewer.
3) Save your python file.

This should restart the OCP Cad Viewer (you should see a logo now) and you should be able to use it normally.
If this fails close Visual Studio Code and restart it and try again.</b>

## Installed Software and changed files and directories

The following software is downloaded and installed:

WinPython a portable python environment:
https://winpython.github.io/

Visual Studio Code:
https://code.visualstudio.com/Download

Visual Studio Code extensions:
https://marketplace.visualstudio.com/VSCode

The Visual Studio Code extensions are installed using Visual Studio Code and the Visual Studio Code Marketplace.
Each Extension has a unique identifier on the marketplace which is used for the installation process.

The following extensions will be installed if not unchecked from the installer:
1) Python (created by Microsoft. UID: ms-python.python)
2) OCP CAD Viewer for VS Code (created by Bernhard Walter. UID: bernhard-42.ocp-cad-viewer)

There are several other extensions I found usefull or which make sense to use like the 
Jupyter Extension for Visual Studio Code (created by Microsoft. UID: ms-toolsai.jupyter)

Also several additional and necessary python packages are installed using pip.
These packages are listed on Bernhard Walters OCP Cad Viewer github website.

As of now these additional python packages are:
cadquery-ocp build123d ipykernel ocp_tessellate ocp_vscode

The installer has a predefined set of python versions, python packages and Visual Studio Code extensions known to work together.
You might change the setup but be aware that it's up to you to test if the new setup will work.

To make Visual Studio Code portable a data directory is added (including subdirectories to hold a potential settings.json)
You can find the directory at:

<b>[Installdirectory]\\[PythonVersionPath]\t\vscode\data</b>

Additional subdirectories are at:

<b>[Installdirectory]\\[PythonVersionPath]\t\vscode\data\user-data\User</b>

The generated launcher calls WinPython's `scripts\env_for_icons.bat` so VS Code
finds the Python interpreter. It leaves `settings\winpython.ini` unchanged.

No additional changes are made unless you enable them to be made (like the desktop link, changes to the workspace json etc.).
