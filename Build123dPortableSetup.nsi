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

# Unicode NSIS with inetc, Nsis7z, and nsisunz (x86-unicode plugins).
Unicode True
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "Sections.nsh"

Name "Portable Build123d"
OutFile "PortableBuild123dSetup.exe"
InstallDir "$PROFILE\Portable_Build123d"
RequestExecutionLevel user

!define MUI_BGCOLOR "fdc514"
# Enlarge the native wizard and every built-in page, including the components tree.
!system 'python "tools\enlarge_ui.py" "${NSISDIR}\Contrib\UIs\modern.exe" ".build-tools\modern-large.exe"' = 0
!define MUI_UI ".build-tools\modern-large.exe"
!define MUI_WELCOMEFINISHPAGE_BITMAP "Data\logo.bmp"
!define MUI_ICON "Data\logo.ico"
!define MUI_HEADERIMAGE_BITMAP "Data\logo-banner.bmp"
!define MUI_FINISHPAGE_LINK_COLOR "0000FF"
!define MUI_FINISHPAGE_LINK "Build123d: https://build123d.readthedocs.io/"
!define MUI_FINISHPAGE_LINK_LOCATION "https://build123d.readthedocs.io/en/latest/index.html"
!define MUI_FINISHPAGE_TEXT "$(FinishText)"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "$(ReadmeText)"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME "https://github.com/CePeU/Build123d-Portable-Installer"

!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE ComponentsLeave
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
Page custom OptionsPage OptionsLeave
Page custom AdvancedDownloadsPage AdvancedDownloadsLeave
Page custom AdvancedExtensionsPage AdvancedExtensionsLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!include "Installer\Variables.nsh"

# English is the fallback. Do not persist language selection to the registry.
!define MUI_LANGDLL_ALLLANGUAGES
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_RESERVEFILE_LANGDLL
!include "Languages\English.nsh"
!include "Languages\German.nsh"

# Sections must precede functions that refer to their section IDs.
!include "Installer\Components.nsh"
!include "Installer\Selection.nsh"

!macro ValidateSetting SECTION VARIABLE
    ${If} ${SectionIsSelected} ${SECTION}
    ${AndIf} $${VARIABLE} == ""
        MessageBox MB_OK|MB_ICONEXCLAMATION "$(EmptySetting)"
        Abort
    ${EndIf}
!macroend
!macro ValidateExtensionSetting SECTION VARIABLE
    ${If} ${SectionIsSelected} ${SECTION}
        StrCpy $ExtensionId $${VARIABLE}
        Call ValidateExtensionId
    ${EndIf}
!macroend
!include "Installer\Pages.nsh"
!include "Installer\Operations.nsh"

!include "Installer\Defaults.nsh"

Function .onInit
    !insertmacro MUI_LANGDLL_DISPLAY
    Call InitializeSettings
    Push 0
    Call ApplyPreset
    SetCurInstType 0
    Call NormalizeSelection
FunctionEnd
