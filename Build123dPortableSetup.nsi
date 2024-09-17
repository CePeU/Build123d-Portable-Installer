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
   
# Version 1.0 alpha
# Basis is the NSIS compiler which can be found here: https://nsis.sourceforge.io/Main_Page
# Additional plug-ins not in the basis download of NSIS.
# uses 7zip plugin: https://nsis.sourceforge.io/Nsis7z_plug-in
# uses inetc download plugin (https download ability): https://nsis.sourceforge.io/Inetc_plug-in
# uses Nsisunz plugin for unziping VsCode: https://nsis.sourceforge.io/Nsisunz_plug-in
# uses nsProcess to check if VSCode is running. This seems to be able to lead to problems: https://nsis.sourceforge.io/NsProcess_plugin
# Also find the creators of the plugins at above URL's

# Define variables
Var WinpythonURL
Var VsCodeURL
Var OCP
Var VsCodePython
Var Jupyter

Var Handle_Winpython
Var Handle_VsCode
Var Handle_OCP
Var Handle_VsCodePython
Var Handle_Jupyter

Var PyPath

Var Python_DownloadLink
Var VSC_DownloadLink

# Include necessary headers
# New GUI Layout
!include "MUI2.nsh"
# Custom Dialog elements
!include "nsDialogs.nsh"
# Allows for if and else statements
!include "LogicLib.nsh"

# Default installation directory (NSIS specific predefined variable)
InstallDir "c:\Portable_Build123d"

# Definitionvariables
!define MUI_BGCOLOR "fdc514"
!define MUI_WELCOMEFINISHPAGE_BITMAP "F:\Code_Projekts\NSIS\logo2.bmp"
!define MUI_ICON "F:\Code_Projekts\NSIS\logo.ico"
!define MUI_HEADERIMAGE_BITMAP "F:\Code_Projekts\NSIS\logo-banner2.bmp"
!define MUI_PAGE_INSTALLDIRECTORY_VARIABLE $InstallDir

!define MUI_FINISHPAGE_LINK_COLOR "FF0000"
!define MUI_FINISHPAGE_LINK "Build123d: https://build123d.readthedocs.io/"
!define MUI_FINISHPAGE_LINK_LOCATION https://build123d.readthedocs.io/en/latest/index.html

# Define the name of the installer
Name "Portable Build123d"
OutFile "PortableBuild123dSetup.exe"


; Request application privileges for Windows Vista and above
RequestExecutionLevel user

# MUI Settings
# https://nsis.sourceforge.io/Docs/Modern%20UI/Readme.html
!insertmacro MUI_PAGE_WELCOME
# Selection Page for Installation directory
!insertmacro MUI_PAGE_DIRECTORY
Page custom DownloadURLPage DownloadURLPageLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"


# Custom page for download path input
# https://nsis.sourceforge.io/Docs/nsDialogs/Readme.html
Function DownloadURLPage
    StrCpy $Python_DownloadLink "https://github.com/winpython/winpython/releases/download/8.2.20240618final/Winpython64-3.12.4.1.exe"
    StrCpy $VSC_DownloadLink "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"

    !insertmacro MUI_HEADER_TEXT "Choose download versions of components" "Choose the URLs (and versions) for Winpython and VsCode. Also choose the VsCode Extensions to install. Use the Marketplace ID for the extensions."

    StrCpy $1 "Code.exe"
    nsProcess::_FindProcess "$1"
    Pop $R0
    ;MessageBox MB_OK "found $R0"
    ${If} $R0 = 0
        ;nsProcess::_KillProcess "$1"
        MessageBox MB_OK "Please close your Visual Studio Code program (Code.exe) and RESTART the installer or the extension install migth FAIL!"
        ;nsProcess::_KillProcess "$1"
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

    ${NSD_CreateLabel} 0 0u 100% 12u "Enter URL for Winpython:"
    Pop $0
    ${NSD_CreateText} 0 12u 100% 12u "$Python_DownloadLink"
    Pop $Handle_Winpython

    ${NSD_CreateLabel} 0 45 100% 12u "Enter URL for VsCode"
    # The label Control Handle is put on the stack
    Pop $0
    # The handel ID ist retrieved with Pop from the stack and the stack is cleared
    
    ${NSD_CreateText} 0 42u 100% 12u "$VSC_DownloadLink"
    # The text control Handle ist put on the stack
    Pop $Handle_VsCode
    # The handel ID ist retrieved with Pop from the stack, this time to DownloadPath variable

    ${NSD_CreateLabel} 0 60u 100% 12u "Enter Marketplace ID for Marketplace Python Extension:"
    Pop $0
    ${NSD_CreateText} 0 73u 100% 12u "ms-python.python"
    Pop $Handle_VsCodePython

    ${NSD_CreateLabel} 0 88u 100% 12u "Enter Marketplace ID for OCP Cad Viewer Extension:"
    Pop $0
    ${NSD_CreateText} 0 101u 100% 12u "bernhard-42.ocp-cad-viewer"
    Pop $Handle_OCP

    ${NSD_CreateLabel} 0 116u 100% 12u "Enter Marketplace ID for Jupyter Extension:"
    Pop $0
    ${NSD_CreateText} 0 127u 100% 12u "ms-toolsai.jupyter"
    Pop $Handle_Jupyter
    

    nsDialogs::Show
FunctionEnd

Function DownloadURLPageLeave
    ${NSD_GetText} $Handle_VsCode $VsCodeURL
    ${NSD_GetText} $Handle_Winpython $WinpythonURL
    ${NSD_GetText} $Handle_OCP $OCP
    ${NSD_GetText} $Handle_VsCodePython $VsCodePython
    ${NSD_GetText} $Handle_Jupyter $Jupyter
FunctionEnd

# Main installation section
Section "DownloadFile" SecDownload
    SetOutPath "$INSTDIR"
  
    CreateDirectory "$INSTDIR\Downloads"
    Pop $0
    
    # Choosing own name for download file as I am not able to safely deduce it from URL
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
    FileWrite $R1 'cmd.exe /k "pip install OCP build123d ipykernel ocp_tessellate ocp_vscode"$\r$\n'
    FileClose $R1
    Pop $R1
    ;MessageBox MB_OK "Filewrite successfull? $R1" --> Could/should make a check here
    DetailPrint "Additional Python packages for Build123d are installing"
    #Call the cmd file to install python packages
    ;nsExec::ExecToLog "$INSTDIR\$PyPath\scripts\Build123dPipPackages.cmd"
    nsExec::ExecToStack "$INSTDIR\$PyPath\scripts\Build123dPipPackages.cmd"
    Pop $0
    Pop $1
    
    ;MessageBox MB_OK "Stack returned $1"
    ;MessageBox MB_OK "Pip Install returned $0"
    
    ;MessageBox MB_OK "Winpython.ini adjustments"
    DetailPrint "Adjusting Winpython.ini with PATH variable so that Vscode finds python"
    # Adding path variable so Visual Studio Code finds python 
    ClearErrors
    FileOpen $R1 "$INSTDIR\$PyPath\settings\winpython.ini" a
    FileSeek $R1 0 END
    FileWrite $R1 '$\r$\nPATH=%PATH%$\r$\n'
    ;If Portable git is necessary - currently it seems not necessary, also would need another download link
    ;FileWrite $R1 '$INSTDIR\$PyPath\PortableGit\bin$\r$\n'
    FileClose $R1
    Pop $R1

    ${Else}
        MessageBox MB_OK "Winpython Download failed: $0"
    ${EndIf}

    # Download Vscode and save it as Vscode.zip as predefinded file name
    inetc::get "$VsCodeURL" "$INSTDIR\Downloads\VsCode.zip" /END
    Pop $0

    ${If} $0 == "OK"
        nsisunz::UnzipToStack "$INSTDIR\Downloads\VsCode.zip" "$INSTDIR\$PyPath\t\"
        Pop $0
        ClearErrors
        DetailPrint "Creating necessary data directory to make VsCode portable"
        CreateDirectory "$INSTDIR\$PyPath\t\data\user-data\User"
        Sleep 2000
            Pop $0
            ${If} ${Errors}
                MessageBox MB_OK "Failed to create directory"
                Abort
            ${Else}
                DetailPrint "Necessary additional Visual Studio Code 'data' directory was created"
                Sleep 3000
            ${EndIf}
        
        # This is a personal preference and could be omitted
        ;DetailPrint "Adjusting VsCode Workspace settings in $INSTDIR\$PyPath\t\data\user-data\User\settings.json"
        ;ClearErrors
        ;FileOpen $R1 "$INSTDIR\$PyPath\t\data\user-data\User\settings.json" a
        ;FileWrite $R1 '{$\r$\n'
        ;FileWrite $R1 '"security.workspace.trust.untrustedFiles": "open",$\r$\n'
        ;FileWrite $R1 '"git.enabled": true,$\r$\n'
        ;FileWrite $R1 '"workbench.colorCustomizations": {$\r$\n'
        ;FileWrite $R1 '"editor.lineHighlightBackground": "#ffffff36",$\r$\n'
        ;FileWrite $R1 '"editor.lineHighlightBorder": "#ffff00"$\r$\n'
        ;FileWrite $R1 '}$\r$\n'
        ;FileClose $R1
        ;Pop $R1
        
        # Installing necessary VsCode extensions
        
        # Check if VSCode is running. If yes the extension installation will fail.
        
        StrCpy $3 "$INSTDIR\$PyPath\t\bin\"
        SetOutPath $3
        

        DetailPrint "Installinng VsCode extension $OCP"
        Sleep 3000
        nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $OCP"'

        DetailPrint "Installing VsCode extension $VsCodePython"
        Sleep 3000
        nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $VsCodePython"'

        DetailPrint "Installing VsCode extension $Jupyter"
        Sleep 3000
        nsExec::ExecToStack  'cmd /k "$outdir\Code.cmd --install-extension $Jupyter"'


    ${Else}
        MessageBox MB_OK "VsCode Download failed: $0"
    ${EndIf}
# No deletion of downloaded files is made, this is intentional for version 1.0 and can easily be changeds
SectionEnd

# To Do and ideas

# Moving the extraction Folder of Winpython was not possible so far - windows does not have a move command and the NSIS solutions suck or do not work (empty directories will not be moved)
# alternativly a copy and delete is possible but a lot of small files makes this SLOW - so I leave it up to the user

# A (apromximal) size check which checks if there is enough room on the install drive

# Some more checks if files have been created or if directories allready exist

# Better GUI/additional page to select some more things as optional --> more extensions, adjustmend of workspace settings.json, desktop links etc.

# Some more explanations in final page

# Ability to choose to create a start menu link

# Enhance language support

