# Sections execute in source order. Shared preparation/finalization are hidden.
InstType "$(PresetBuild123d)"
InstType "$(PresetVsCode)"
InstType /CUSTOMSTRING="$(PresetCustom)"

Section "-Prepare" SecPrepare
    SectionIn 1 2 RO
    Call NormalizeSelection
    ClearErrors
    CreateDirectory "$INSTDIR\Downloads"
    ${If} ${Errors}
        MessageBox MB_OK|MB_ICONSTOP "$(CreateDirectoryFailed)" /SD IDOK
        Abort
    ${EndIf}
    StrCpy $VsCodeINSTDIR "$INSTDIR"
SectionEnd

SectionGroup /e "$(GroupPython)" GroupPython
Section "WinPython" SecWinPython
    SectionIn 1
    # Estimates in KiB, including download/extraction headroom.
    AddSize 500000
    Call InstallWinPython
SectionEnd
Section "$(ComponentPackages)" SecPackages
    SectionIn 1
    AddSize 800000
    StrCpy $PackageList "cadquery-ocp build123d ipykernel ocp_tessellate ocp_vscode"
    Call InstallPythonPackages
SectionEnd
Section /o "Cadquery" SecCadquery
    AddSize 200000
    StrCpy $PackageList "cadquery"
    Call InstallPythonPackages
SectionEnd
SectionGroupEnd

SectionGroup /e "Visual Studio Code" GroupVsCode
Section "$(ComponentEditor)" SecVsCode
    SectionIn 1 2
    AddSize 600000
    Call InstallVsCode
SectionEnd

!macro ExtensionSection LABEL ID VARIABLE PRESET SIZE
Section /o "${LABEL}" ${ID}
    ${PRESET}
    AddSize ${SIZE}
    StrCpy $ExtensionId $${VARIABLE}
    Call InstallExtension
SectionEnd
!macroend
!insertmacro ExtensionSection "$(ComponentPythonExtension)" SecPythonExtension VsCodePython "SectionIn 1" 150000
!insertmacro ExtensionSection "OCP CAD Viewer" SecOCP OCP "SectionIn 1" 100000
!insertmacro ExtensionSection "Jupyter" SecJupyter Jupyter "SectionIn 1" 150000
!insertmacro ExtensionSection "Black Formatter" SecBlack BlackFormatter "" 30000
!insertmacro ExtensionSection "Frame Indent Rainbow" SecFrame FrameIndentRainbow "" 5000
!insertmacro ExtensionSection "STL Viewer" SecSTL STLviewer "" 10000
!insertmacro ExtensionSection "$(ComponentSvg)" SecSVG SVGviewer "" 10000
SectionGroupEnd

SectionGroup /e "$(GroupVersionControl)" GroupVersionControl
Section /o "Portable Git (x64)" SecGit
    AddSize 400000
    Call InstallGit
SectionEnd
Section /o "$(ComponentFossil)" SecFossil
    AddSize 20000
    Call InstallFossil
    StrCpy $ExtensionId "koog1000.fossil"
    Call InstallExtension
SectionEnd
SectionGroupEnd

SectionGroup /e "$(GroupHelpers)" GroupHelpers
Section /o "$(ComponentLaunchers)" SecLaunchers
    AddSize 1
    Call CreateThumbdriveScript
SectionEnd
Section /o "$(ComponentSnippets)" SecSnippets
    SetOutPath "$VsCodeINSTDIR\data\user-data\User\snippets"
    File "Data\build123d-OCP.code-snippets"
SectionEnd
SectionGroupEnd

Section "-Finalize" SecFinalize
    SectionIn 1 2 RO
    Call FinalizeInstallation
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${GroupPython} "$(DescPythonGroup)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecWinPython} "$(DescWinPython)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPackages} "$(DescPackages)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCadquery} "$(DescCadquery)"
    !insertmacro MUI_DESCRIPTION_TEXT ${GroupVsCode} "$(DescVsCode)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecVsCode} "$(DescVsCode)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPythonExtension} "$(DescPythonExtension)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecOCP} "$(DescOCP)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecJupyter} "$(DescJupyter)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecBlack} "$(DescBlack)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecFrame} "$(DescFrame)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSTL} "$(DescSTL)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSVG} "$(DescSVG)"
    !insertmacro MUI_DESCRIPTION_TEXT ${GroupVersionControl} "$(DescVersionControl)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecGit} "$(DescGit)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecFossil} "$(DescFossil)"
    !insertmacro MUI_DESCRIPTION_TEXT ${GroupHelpers} "$(DescHelpers)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLaunchers} "$(DescLaunchers)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSnippets} "$(DescSnippets)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
