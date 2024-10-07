/*Copyright 2024 CePeU

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.*/

# Basis is the NSIS compiler which can be found here: https://nsis.sourceforge.io/Main_Page
# Additional plug-ins not in the basis download of NSIS.
# uses 7zip plugin: https://nsis.sourceforge.io/Nsis7z_plug-in
# uses inetc download plugin (https download ability): https://nsis.sourceforge.io/Inetc_plug-in
# uses Nsisunz plugin for unziping VsCode: https://nsis.sourceforge.io/Nsisunz_plug-in
# uses nsProcess to check if VSCode is running. This seems to be able to lead to problems: https://nsis.sourceforge.io/NsProcess_plugin
# Also find the creators of the plugins at above URL's and any legal text
!verbose 4
!echo "NSIS ${NSIS_VERSION} (${NSIS_PACKEDVERSION}, CS=${NSIS_CHAR_SIZE}, ${NSIS_CPU})"

Unicode True
# Define variables
Var WinpythonURL
Var VsCodeURL
Var OCP
Var VsCodePython
Var Jupyter
Var STLviewer
Var SVGviewer
Var FrameIndentRainbow
Var BlackFormatter

Var WinpythonURL_Checkbox
Var VsCodeURL_Checkbox
Var OCP_Checkbox
Var VsCodePython_Checkbox
Var Jupyter_Checkbox
Var STLviewer_Checkbox
Var SVGviewer_Checkbox
Var FrameIndentRainbow_Checkbox
Var BlackFormatter_Checkbox


Var Handle_Winpython
Var Handle_VsCode
Var Handle_OCP
Var Handle_VsCodePython
Var Handle_Jupyter
Var Handle_STLviewer
Var Handle_SVGviewer
Var Handle_FrameIndentRainbow
Var Handle_BlackFormatter


Var Handle_Winpython_Checkbox
Var Handle_VsCode_Checkbox
Var Handle_OCP_Checkbox
Var Handle_VsCodePython_Checkbox
Var Handle_Jupyter_Checkbox
Var Handle_STLviewer_Checkbox
Var Handle_SVGviewer_Checkbox
Var Handle_FrameIndentRainbow_Checkbox
Var Handle_BlackFormatter_Checkbox


Var PyPath

Var Python_DownloadLink
Var VSC_DownloadLink
Var VsCodeINSTDIR

# Include necessary headers
# New GUI Layout
!include "MUI2.nsh"
# Custom Dialog elements
!include "nsDialogs.nsh"
# Allows for if and else statements
!include "LogicLib.nsh"

# Default installation directory (NSIS specific predefined variable)
# No satisfactory default path was found yet. ProgramFiles is not advised for windows.
# The Home directory path is so deeply stacked that nobody will find the files again.
# https://nsis.sourceforge.io/Docs/Chapter4.html#varconstant 4.2.3
InstallDir "$Profile\Portable_Build123d"
;InstallDir "$ProgramFiles64\Portable_Build123d"
;InstallDir "C:\Portable_Build123d"

# Define the name of the installer
Name "Portable Build123d"
;OutFile "${NSISDIR}\PortableBuild123dSetup.exe"
OutFile "PortableBuild123dSetup.exe"

# Request application privileges for Windows Vista and above
# https://nsis.sourceforge.io/Reference/RequestExecutionLevel#:~:text=Specifies%20the%20requested%20execution%20level%20for
# none|user|highest|admin
RequestExecutionLevel user

# Definitionvariables
!define MUI_BGCOLOR "fdc514"
!define MUI_WELCOMEFINISHPAGE_BITMAP "Data\logo.bmp"
!define MUI_ICON "Data\logo.ico"
!define MUI_HEADERIMAGE_BITMAP "Data\logo-banner.bmp"
!define MUI_PAGE_INSTALLDIRECTORY_VARIABLE $InstallDir

!define MUI_FINISHPAGE_LINK_COLOR "0000FF"
!define MUI_FINISHPAGE_LINK "Build123d: https://build123d.readthedocs.io/"
!define MUI_FINISHPAGE_LINK_LOCATION https://build123d.readthedocs.io/en/latest/index.html
!define MUI_FINISHPAGE_TEXT "Portable Build123d has been installed on your computer.$\r$\nClick Finish to close Setup.$\r$\n$\r$\nIMPORTANT! Use the weblink for latest Information!."

!define MUI_FINISHPAGE_SHOWREADME_TEXT "Build123dSetup website with important install information!"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME "https://github.com/CePeU/Build123d-Portable-Installer"

# MUI Settings
# https://nsis.sourceforge.io/Docs/Modern%20UI/Readme.html
!insertmacro MUI_PAGE_WELCOME
# Selection Page for Installation directory
!insertmacro MUI_PAGE_DIRECTORY
Page custom DownloadURLPage DownloadURLPageLeave
Page custom ExtensionsPage ExtensionsPageLeave
Page custom SpecialsPage SpecialsPageLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"


Var Handle_Git_Checkbox
Var Handle_Git
Var Git_DownloadLink
Var Git_Checkbox
Var GitURL

Var Handle_Fossil_Checkbox
Var Handle_Fossil
Var Fossil_DownloadLink
Var Fossil_Checkbox
Var FossilURL

# Custom page for download path input
# https://nsis.sourceforge.io/Docs/nsDialogs/Readme.html
Function DownloadURLPage

    # WinPython download path
    StrCpy $Python_DownloadLink "https://github.com/winpython/winpython/releases/download/8.2.20240618final/Winpython64-3.12.4.1dot.exe"
    
    # Visual Studio Code ZIP page: https://code.visualstudio.com/docs/?dv=winzip
    # Visual Studio Updates page also for older revisions: https://code.visualstudio.com/updates/
    # Visual studio code ZIP page to download a SPECIFIC version: https://update.code.visualstudio.com/1.94.0/win32-x64-archive/stable
    # ZIP files are found under: win32-x64-archive and EXE files are found under: win32-x64-user
    StrCpy $VSC_DownloadLink "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"

    # Two possible version control systems
    StrCpy $Git_DownloadLink "https://github.com/git-for-windows/git/releases/download/v2.46.1.windows.1/PortableGit-2.46.1-64-bit.7z.exe"
    StrCpy $Fossil_DownloadLink "https://www.fossil-scm.org/home/uv/fossil-w64-2.24.zip"

    !insertmacro MUI_HEADER_TEXT "Choose download versions of components" "Choose the URLs (and versions) for Winpython and VsCode."

    StrCpy $1 "Code.exe"
    nsProcess::_FindProcess "$1"
    Pop $R0

    ${If} $R0 = 0
        MessageBox MB_OK "Please close your Visual Studio Code program (Code.exe) and RESTART the installer or the extension install might FAIL!"
        Pop $R0
        Sleep 500
    ${EndIf}

    nsDialogs::Create 1018
    # The Windows Handle is put on the stack
    Pop $0
    # The handel ID ist retrieved with Pop from the stack and the stack is cleared
    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateCheckBox} 0 0 100% 12u "Install Winpython: Change URL below for a different version."
    Pop $Handle_Winpython_Checkbox
    ${NSD_Check} $Handle_Winpython_Checkbox
    ${NSD_CreateText} 0 12u 100% 12u "$Python_DownloadLink"
    Pop $Handle_Winpython

    ${NSD_CreateCheckBox} 0 26u 100% 12u "Install VsCode: Change URL below for a different version."
    Pop $Handle_VsCode_Checkbox
    ${NSD_Check} $Handle_VsCode_Checkbox
    ${NSD_CreateText} 0 39u 100% 12u "$VSC_DownloadLink"
    # The text control Handle ist put on the stack
    Pop $Handle_VsCode
    # The handel ID ist retrieved with Pop from the stack, this time to DownloadPath variable

    ${NSD_CreateCheckBox} 0 55u 100% 12u "Install Portable Git (x64): Change URL below for a different version."
    Pop $Handle_Git_Checkbox
    ;${NSD_Check} $Handle_Git_Checkbox
    ${NSD_CreateText} 0 68u 100% 12u "$Git_DownloadLink"
    Pop $Handle_Git

    ${NSD_CreateCheckBox} 0 84u 100% 12u "Install Fossil (x64) version control system: Change URL below for a different version."
    Pop $Handle_Fossil_Checkbox
    ;${NSD_Check} $Handle_Fossil_Checkbox
    ${NSD_CreateText} 0 97u 100% 12u "$Fossil_DownloadLink"
    Pop $Handle_Fossil

    nsDialogs::Show
FunctionEnd

Function DownloadURLPageLeave
    ${NSD_GetState} $Handle_VsCode_Checkbox $VsCodeURL_Checkbox
    ${NSD_GetText} $Handle_VsCode $VsCodeURL
    ${NSD_GetState} $Handle_Winpython_Checkbox $WinpythonURL_Checkbox
    ${NSD_GetText} $Handle_Winpython $WinpythonURL

    ${NSD_GetState} $Handle_Git_Checkbox $Git_Checkbox
    ${NSD_GetText} $Handle_Git $GitURL

    ${NSD_GetState} $Handle_Fossil_Checkbox $Fossil_Checkbox
    ${NSD_GetText} $Handle_Fossil $FossilURL
    
FunctionEnd

Function ExtensionsPage
    
    !insertmacro MUI_HEADER_TEXT "Choose Visual Studio Code extensions" "Choose Visual Studio Code extensions to be installed. Use the Marketplace ID for the extensions."

    nsDialogs::Create 1018
    # The Windows Handle is put on the stack
    Pop $0
    # The handel ID ist retrieved with Pop from the stack and the stack is cleared
    ${If} $0 == error
        Abort
    ${EndIf}
    
    ${NSD_CreateCheckBox} 0 0u 23% 12u "OCP Cad Viewer:"
    Pop $Handle_OCP_Checkbox
    ${NSD_Check} $Handle_OCP_Checkbox
    ${NSD_CreateText} 23% 0u 35% 12u "bernhard-42.ocp-cad-viewer"
    Pop $Handle_OCP

    ${NSD_CreateCheckBox} 60% 0u 14% 12u "Python:"
    Pop $Handle_VsCodePython_Checkbox
    ${NSD_Check} $Handle_VsCodePython_Checkbox
    ${NSD_CreateText} 74% 0u 26% 12u "ms-python.python"
    Pop $Handle_VsCodePython

    ${NSD_CreateCheckBox} 0 26u 23% 12u "Frame-Indent:"
    Pop $Handle_FrameIndentRainbow_Checkbox
    ${NSD_CreateText} 23% 26u 35% 12u "firejump.frame-indent-rainbow"
    Pop $Handle_FrameIndentRainbow
    
    ${NSD_CreateCheckBox} 60% 26u 14% 12u "Jupyter:"
    Pop $Handle_Jupyter_Checkbox
    ${NSD_CreateText} 74% 26u 26% 12u "ms-toolsai.jupyter"
    Pop $Handle_Jupyter

    ${NSD_CreateCheckBox} 0 52u 23% 12u "BlackFormatter:"
    Pop $Handle_BlackFormatter_Checkbox
    ${NSD_CreateText} 23% 52u 35% 12u "ms-python.black-formatter"
    Pop $Handle_BlackFormatter

    ${NSD_CreateCheckBox} 0 78u 23% 12u "STL Viewer:"
    Pop $Handle_STLviewer_Checkbox
    ${NSD_CreateText} 23% 78u 35% 12u "mtsmfm.vscode-stl-viewer"
    Pop $Handle_STLviewer
    
    ${NSD_CreateCheckBox} 0 104u 23% 12u "SVG preview:"
    Pop $Handle_SVGviewer_Checkbox
    ${NSD_CreateText} 23% 104u 35% 12u "simonsiefke.svg-preview"
    Pop $Handle_SVGviewer


    nsDialogs::Show
FunctionEnd

Function ExtensionsPageLeave
    ${NSD_GetState} $Handle_OCP_Checkbox $OCP_Checkbox
    ${NSD_GetState} $Handle_VsCodePython_Checkbox $VsCodePython_Checkbox
    
    ${NSD_GetState} $Handle_Jupyter_Checkbox $Jupyter_Checkbox
    ${NSD_GetState} $Handle_FrameIndentRainbow_Checkbox $FrameIndentRainbow_Checkbox
    ${NSD_GetState} $Handle_BlackFormatter_Checkbox $BlackFormatter_Checkbox
    ${NSD_GetState} $Handle_STLviewer_Checkbox $STLviewer_Checkbox
    ${NSD_GetState} $Handle_SVGviewer_Checkbox $SVGviewer_Checkbox

    ${NSD_GetText} $Handle_OCP $OCP
    ${NSD_GetText} $Handle_VsCodePython $VsCodePython
    
    ${NSD_GetText} $Handle_Jupyter $Jupyter
    ${NSD_GetText} $Handle_FrameIndentRainbow $FrameIndentRainbow
    ${NSD_GetText} $Handle_BlackFormatter $BlackFormatter
    ${NSD_GetText} $Handle_STLviewer $STLviewer
    ${NSD_GetText} $Handle_SVGviewer $SVGviewer
FunctionEnd


Var Workspace_Checkbox
Var Handle_Workspace_Checkbox
Var Snippet_Checkbox
Var Handle_Snippet_Checkbox
Var Cadquery_Checkbox
Var Handle_Cadquery_Checkbox
Var StartCMD_Checkbox
Var Handle_StartCMD_Checkbox
Var Shortcut_Checkbox
Var Handle_Shortcut_Checkbox
Var Cleanup_Checkbox
Var Handle_Cleanup_Checkbox


Function SpecialsPage

    !insertmacro MUI_HEADER_TEXT "Additional Installations" "Install additonal stuff prefered by the developer"
    
    nsDialogs::Create 1018
    # The Windows Handle is put on the stack
    Pop $0
    # The handel ID ist retrieved with Pop from the stack and the stack is cleared
    ${If} $0 == error
        Abort
    ${EndIf}
    
    ${NSD_CreateCheckBox} 0 56u 100% 12u "Install Cadquery"
    Pop $Handle_Cadquery_Checkbox

    ${NSD_CreateCheckBox} 0 28u 50% 12u "Workspace adjustments"
    Pop $Handle_Workspace_Checkbox

    ${NSD_CreateCheckBox} 0 42u 50% 12u "Vscode Build123d snippets"
    Pop $Handle_Snippet_Checkbox

    ${NSD_CreateCheckBox} 0 14u 60% 12u "ThumbdriveAdjustment.cmd and Vscode.cmd"
    Pop $Handle_StartCMD_Checkbox
    
    ${NSD_CreateCheckBox} 0 0u 50% 12u "Create desktop shortcut"
    Pop $Handle_Shortcut_Checkbox

    ${NSD_CreateCheckBox} 0 70u 50% 12u "Cleanup and remove install files"
    Pop $Handle_Cleanup_Checkbox
    ${NSD_Check} $Handle_Cleanup_Checkbox
    nsDialogs::Show
FunctionEnd

Function SpecialsPageLeave
    ${NSD_GetState} $Handle_Cadquery_Checkbox $Cadquery_Checkbox
    ${NSD_GetState} $Handle_Workspace_Checkbox $Workspace_Checkbox
    ${NSD_GetState} $Handle_Snippet_Checkbox $Snippet_Checkbox
    ${NSD_GetState} $Handle_StartCMD_Checkbox $StartCMD_Checkbox
    ${NSD_GetState} $Handle_Shortcut_Checkbox $Shortcut_Checkbox
    ${NSD_GetState} $Handle_Cleanup_Checkbox $Cleanup_Checkbox
FunctionEnd

# Main installation section
Section "DownloadFile" SecDownload
AddSize 2256000
    CreateDirectory "$INSTDIR\Downloads"
    Pop $0 
    SetOutPath "$INSTDIR"

    # Choosing own name for download file as I am not able to safely deduce it from URL    
    ${If} $WinpythonURL_Checkbox == 1
        
        inetc::get "$WinpythonURL" "$INSTDIR\Downloads\Winpython.exe" /END
        Pop $0
        
        ${If} $0 == "OK"
            Nsis7z::ExtractWithDetails "$INSTDIR\Downloads\Winpython.exe" "Installing WinPython %s..."
            # Find the name of the python folder (which might change from version to version)
            FindFirst $0 $1 "$INSTDIR\WPy64*.*"
            loop:
                StrCmp $1 "" done
                StrCpy $PyPath $1
                FindNext $0 $1
                Goto loop
            done:
            FindClose $0
            # Install needed pip packages 
            ClearErrors
            # Cmd File for installing the missing Build123d Python packages
            FileOpen $R1 "$INSTDIR\$PyPath\scripts\Build123dPipPackages.cmd" w
            FileWrite $R1 '@echo off$\r$\n'
            FileWrite $R1 'call "%~dp0env_for_icons.bat"  %*$\r$\n'
            FileWrite $R1 'if not "%WINPYWORKDIR%"=="%WINPYWORKDIR1%" cd %WINPYWORKDIR1%$\r$\n'
            
                ${if} $Cadquery_Checkbox == 1
                    FileWrite $R1 'cmd.exe /k "pip install cadquery cadquery-ocp build123d ipykernel ocp_tessellate ocp_vscode"$\r$\n'
                ${Else}
                    FileWrite $R1 'cmd.exe /k "pip install cadquery-ocp build123d ipykernel ocp_tessellate ocp_vscode"$\r$\n'
                ${EndIf}
            FileClose $R1
            Pop $R1
            ;MessageBox MB_OK "Filewrite successfull? $R1" --> Could/should make a check here
            DetailPrint "Additional Python packages for Build123d are installing"
            #Call the cmd file to install python packages
            nsExec::ExecToStack "$INSTDIR\$PyPath\scripts\Build123dPipPackages.cmd"
            Pop $0
            Pop $1

            DetailPrint "Adjusting Winpython.ini with PATH variable so that Vscode finds python"
            # Adding path variable so Visual Studio Code finds python, Git and Fossil 
            ClearErrors
            FileOpen $R1 "$INSTDIR\$PyPath\settings\winpython.ini" a
            FileSeek $R1 0 END
            FileWrite $R1 '$\r$\nPATH=%PATH%'
            ${if} $Git_Checkbox == 1
                FileWrite $R1 ";$INSTDIR\$PyPath\t\data\GitPortable\bin"
            ${EndIf}
            ${if} $Fossil_Checkbox == 1
                FileWrite $R1 ";$INSTDIR\$PyPath\t\data\Fossil"            
            ${EndIf}
            FileWrite $R1 '$\r$\n'
            FileClose $R1
            Pop $R1
            ${Else}
            MessageBox MB_OK "Winpython Download failed: $0"
        ${EndIf}
    ${Endif} #Endif of installation of python

    # Create path if only VScode is to be installed
    ${If} $WinpythonURL_Checkbox == 1
            StrCpy $VsCodeINSTDIR "$INSTDIR\$PyPath\t\vscode"
        ${Else}
            StrCpy $VsCodeINSTDIR "$INSTDIR"
    ${EndIf}

    # Download Vscode and save it as Vscode.zip as predefinded file name
    ${if} $VsCodeURL_Checkbox == 1
        inetc::get "$VsCodeURL" "$INSTDIR\Downloads\VsCode.zip" /END
        Pop $0
        ${If} $0 == "OK"
            ClearErrors
            nsisunz::UnzipToStack "$INSTDIR\Downloads\VsCode.zip" "$VsCodeINSTDIR"
            Pop $0
            ${If} ${Errors}
                MessageBox MB_OK  "Could not unzip VsCode"
                Abort
            ${EndIf}
            ClearErrors
            DetailPrint "Creating necessary data directory to make VsCode portable"
            CreateDirectory "$VsCodeINSTDIR\data\user-data\User"
            CreateDirectory "$VsCodeINSTDIR\data\tmp"
            Pop $0
            Sleep 4000
            ${If} ${Errors}
                MessageBox MB_OK "Failed to create directory"
                Abort
                ${Else}
                DetailPrint "Necessary additional Visual Studio Code 'data' directory was created"
                Sleep 4000
            ${EndIf}
    
            # Download Fossil SVN and save it as Fossil.zip as predefinded file name
            ${if} $Fossil_Checkbox == 1
                inetc::get "$FossilURL" "$INSTDIR\Downloads\Fossil.zip" /END
                Pop $0

                ${If} $0 == "OK"
                    ClearErrors
                    DetailPrint "Creating seperate directory for Fossil SVN"
                    CreateDirectory "$VsCodeINSTDIR\data\Fossil"
                    Sleep 4000
                    Pop $0
                    ${If} ${Errors}
                        MessageBox MB_OK "Failed to create directory"
                        Abort
                        ${Else}
                        DetailPrint "Fossil directory was created"
                        Sleep 4000
                    ${EndIf}
                    ClearErrors
                    nsisunz::UnzipToStack "$INSTDIR\Downloads\Fossil.zip" "$VsCodeINSTDIR\data\Fossil"
                    Pop $0
                    ${If} ${Errors}
                        MessageBox MB_OK  "Could not unzip Fossil source control"
                        Abort
                    ${EndIf}
                    ${Else}
                    MessageBox MB_OK "Fossil Download failed: $0"
                ${EndIf}
            ${EndIf}

            # Download Git Portable and save it as Git.zip as predefinded file name
            ${if} $Git_Checkbox == 1
                
                inetc::get "$GitURL" "$INSTDIR\Downloads\Git.zip" /END
                Pop $0
                ${If} $0 == "OK"
                        ClearErrors
                        DetailPrint "Creating seperate directory for Git SVN"
                        CreateDirectory "$VsCodeINSTDIR\data\GitPortable"
                        Sleep 4000
                        Pop $0
                        ${If} ${Errors}
                                MessageBox MB_OK "Failed to create directory"
                                Abort
                            ${Else}
                                DetailPrint "GitPortable directory was created"
                                Sleep 4000
                        ${EndIf}
                        StrCpy $3 "$VsCodeINSTDIR\data\GitPortable\"
                        SetOutPath $3
                        ClearErrors
                        Nsis7z::ExtractWithDetails "$INSTDIR\Downloads\Git.zip" "Installing Git Portable %s..."
                        ;nsisunz::UnzipToStack "$INSTDIR\Downloads\Git.zip" "$VsCodeINSTDIR\data\GitPortable"
                        Pop $0                        
                        ${If} ${Errors}
                            MessageBox MB_OK  "Could not unzip Git source control"
                            Abort
                        ${EndIf}
                    ${Else}
                        MessageBox MB_OK "Git portable Download failed: $0"
                ${EndIf}
            ${EndIf}

            ${if} $Workspace_Checkbox == 1
                # This is a personal preference and can all be omitted
                DetailPrint "Adjusting VsCode Workspace settings in $VsCodeINSTDIR\data\user-data\User\settings.json"
                Sleep 4000
                ClearErrors
                FileOpen $R1 "$VsCodeINSTDIR\data\user-data\User\settings.json" a
                FileWrite $R1 '{$\r$\n'
                FileWrite $R1 '"security.workspace.trust.untrustedFiles": "open",$\r$\n'
                ${if} $Git_Checkbox == 1
                    FileWrite $R1 '"git.enabled": true,$\r$\n'
                ${EndIf}
                FileWrite $R1 '"workbench.colorCustomizations": {$\r$\n'
                FileWrite $R1 '"editor.lineHighlightBackground": "#ffffff36",$\r$\n'
                FileWrite $R1 '"editor.lineHighlightBorder": "#ffff00"$\r$\n'
                FileWrite $R1 '}$\r$\n'
                FileWrite $R1 '}$\r$\n'
                FileClose $R1
                Pop $R1
            ${EndIf}

            # Scipt needs adjusting for VsCode only install and maybe for fossil and git
            ${if} $StartCMD_Checkbox == 1
                DetailPrint "Creating VsCode ThumbdriveAdjust.cmd"
                Sleep 4000
                ${If} $WinpythonURL_Checkbox == 1
                        FileOpen $R1 "$INSTDIR\$PyPath\ThumbdriveAdjust.cmd" w
                    ${Else}
                        FileOpen $R1 "$VsCodeINSTDIR\ThumbdriveAdjust.cmd" w
                ${Endif}
                ClearErrors
                FileWrite $R1 "set drivepath=%CD%$\r$\n"
                ${if} $WinpythonURL_Checkbox == 1
                        FileWrite $R1 "set OutputTo=%drivepath%\settings\winpython.ini$\r$\n"
                        FileWrite $R1 "ren %drivepath%\settings\winpython.ini winpython.old$\r$\n"
                        FileWrite $R1 "echo [debug]>%OutputTo%$\r$\n"
                        FileWrite $R1 "echo state = disabled>>%OutputTo%$\r$\n"
                        FileWrite $R1 "echo [environment]>>%OutputTo%$\r$\n"
                    ${Else}
                        FileWrite $R1 "ren %drivepath%\VsCode.cmd VsCode.old$\r$\n"
                        FileWrite $R1 "set OutputTo=%drivepath%\VsCode.cmd$\r$\n"
                ${EndIf}   
                FileWrite $R1 "echo PATH=%%PATH%%"
                ${if} $Git_Checkbox == 1
                    ${if} $WinpythonURL_Checkbox == 1
                            FileWrite $R1 ";%drivepath%\t\data\GitPortable\bin"
                        ${Else}
                            FileWrite $R1 ";%drivepath%\data\GitPortable\bin"   
                    ${EndIf}
                ${EndIf}
                ${if} $Fossil_Checkbox == 1
                    ${if} $WinpythonURL_Checkbox == 1
                            FileWrite $R1 ";%drivepath%\t\data\Fossil"
                        ${Else}
                            FileWrite $R1 ";%drivepath%\data\Fossil\"   
                    ${EndIf}
                ${EndIf}
                Filewrite $R1 ">>%OutputTo%$\r$\n"
                ${if} $WinpythonURL_Checkbox == 1
                        FileWrite $R1 'start "" "VS Code.exe"$\r$\n'
                    ${Else}
                        FileWrite $R1 'echo start "" "%drivepath%\Code.exe">>%OutputTo%$\r$\n'
                        FileWrite $R1 'call "VsCode.cmd"$\r$\n'
                ${EndIf}
                FileClose $R1
                Pop $R1
            ${EndIf}
        

            ${if} $StartCMD_Checkbox == 1
                ${If} $WinpythonURL_Checkbox <> 1
                    DetailPrint "Creating VsCode.cmd'"
                    Sleep 4000
                    FileOpen $R1 "$VsCodeINSTDIR\VsCode.cmd" w
                    FileWrite $R1 "PATH=%PATH%"
                    ${if} $Git_Checkbox == 1
                        FileWrite $R1 ";$VsCodeINSTDIR\data\GitPortable\bin"   
                    ${EndIf}
                    ${if} $Fossil_Checkbox == 1
                        FileWrite $R1 ";$VsCodeINSTDIR\data\Fossil"
                    ${EndIf}
                    Filewrite $R1 "$\r$\n"
                    Filewrite $R1 'start "" "$VsCodeINSTDIR\Code.exe"$\r$\n'
                    FileClose $R1
                    Pop $R1
                ${EndIf}
            ${EndIf}

            # Installing necessary VsCode extensions
            # Check if VSCode is running. If yes the extension installation will fail. This seems to be mainly the case if the setup is compiled and directly run
            # from VsCode. Possibly it is because of the paths in the portable setup which is also used for development. But better safe than sorry. Also it helps
            # as a reminder for the developer.

            StrCpy $3 "$VsCodeINSTDIR\bin\"
            SetOutPath $3
            
            ${if} $OCP_Checkbox == 1
                DetailPrint "Installing VsCode extension $OCP"
                Sleep 4000
                nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $OCP"'
            ${EndIf}

            ${if} $VsCodePython_Checkbox == 1
                DetailPrint "Installing VsCode extension $VsCodePython"
                Sleep 4000
                nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $VsCodePython"'
            ${EndIf}
            
            ${if} $Jupyter_Checkbox == 1
                DetailPrint "Installing VsCode extension $Jupyter"
                Sleep 4000
                nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $Jupyter"'
            ${EndIf}

            ${if} $FrameIndentRainbow_Checkbox == 1
                DetailPrint "Installing VsCode extension $FrameIndentRainbow"
                Sleep 4000
                nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $FrameIndentRainbow"'
            ${EndIf}

            ${if} $STLviewer_Checkbox == 1
                DetailPrint "Installing VsCode extension $STLviewer"
                Sleep 4000
                nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $STLviewer"'
            ${EndIf}

            ${if} $BlackFormatter_Checkbox == 1
                DetailPrint "Installing VsCode extension $BlackFormatter"
                Sleep 4000
                nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $BlackFormatter"'
            ${EndIf}
        
            ${if} $SVGviewer_Checkbox == 1
                DetailPrint "Installing VsCode extension $SVGviewer"
                Sleep 4000
                nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $SVGviewer"'
            ${EndIf}

            ${if} $Fossil_Checkbox == 1
                DetailPrint "Installing VsCode extension for Fossil"
                Sleep 4000
                nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension koog1000.fossil'
            ${EndIf}

            ${if} $Shortcut_Checkbox  == 1
                ${if} $WinpythonURL_Checkbox == 1
                        CreateShortcut "$desktop\Build123d.lnk" "$INSTDIR\$PyPath\Vs Code.exe" 
                    ${Else}
                        CreateShortcut "$desktop\VsCode_Portable.lnk" "$VsCodeINSTDIR\VsCode.cmd"
                ${Endif}
            ${EndIf}

            ${if} $Snippet_Checkbox == 1
                SetOutPath "$VsCodeINSTDIR\data\user-data\User\snippets"
                File "Data\build123d-OCP.code-snippets"
            ${EndIf}

            ${Else}
                MessageBox MB_OK "VsCode Download failed: $0"
        ${EndIf}
    ${EndIf}

    ${if} $Cleanup_Checkbox == 1
        RMDir /r "$INSTDIR\Downloads"
        ${if} $WinpythonURL_Checkbox == 1
            Delete "$INSTDIR\$PyPath\scripts\Build123dPipPackages.cmd"
        ${EndIf}
    ${EndIf}
    
SectionEnd
