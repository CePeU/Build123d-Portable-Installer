# Build123d-Portable-Installer

## General Information and first start
This is a NSIS based installer for a portable Windows IDE environment for build123d, python and VsCode.

Build123d-Portable-Installer is a web installer. It allows you to download the necessary software and to
install it. During the setup some files are modified  to allow for a fully portable setup.

Fully portable means that you can install and delete the software setup without any registry changes or
other dependencies. You can copy the installation to any hard drive you like. You also can use it on your 
USB thumb drive - just copy your installation there. 
Install it with the thumbdrive option and execute ThumbdriveAdjust.cmd after the copy operation and you are
ready to go. 
For this reason you also can uncheck the python part and use the installer as
a setup for a portable Visual Studio Code setup (In that case use VsCode.cmd to start you VsCode session).

After the installation you can start VsCode under this path:<br>
<b>[Installdirectory]\\[PythonVersionPath]\t\Vs Code.exe</b>

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
OCP build123d ipykernel ocp_tessellate ocp_vscode

The installer has a predefined set of python versions, python packages and Visual Studio Code extensions known to work together.
You might change the setup but be aware that it's up to you to test if the new setup will work.

To make Visual Studio Code portable a data directory is added (including subdirectories to hold a potential settings.json)
You can find the directory at:

<b>[Installdirectory]\\[PythonVersionPath]\t\data</b>

Additional subdirectories are at:

<b>[Installdirectory]\\[PythonVersionPath]\t\data\user-data\User</b>

WinPython is modified to hold the PATH so Visual Studio finds the python interpreter.
You can find the file at:

<b>[Installdirectory]\\[PythonVersionPath]\settings\winpython.ini</b>

No additional changes are made unless you enable them to be made (like the desktop link, changes to the workspace json etc.).
