# Settings are initialized once in .onInit. Controls always use saved values.
!macro SettingRow LABEL VARIABLE HANDLE Y SECTION
    ${NSD_CreateLabel} 0 ${Y}u 29% 12u "${LABEL}"
    Pop $0
    ${NSD_CreateText} 30% ${Y}u 70% 12u "$${VARIABLE}"
    Pop $${HANDLE}
    ${IfNot} ${SectionIsSelected} ${SECTION}
        EnableWindow $${HANDLE} 0
    ${EndIf}
!macroend

Function AdvancedDownloadsPage
    ${If} $AdvancedOption != ${BST_CHECKED}
        Abort
    ${EndIf}
    !insertmacro MUI_HEADER_TEXT "$(AdvancedDownloadsTitle)" "$(AdvancedDownloadsSubtitle)"
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    !insertmacro SettingRow "WinPython" WinpythonURL Handle_Winpython 0 ${SecWinPython}
    !insertmacro SettingRow "Visual Studio Code" VsCodeURL Handle_VsCode 28 ${SecVsCode}
    !insertmacro SettingRow "Portable Git" GitURL Handle_Git 56 ${SecGit}
    !insertmacro SettingRow "Fossil" FossilURL Handle_Fossil 84 ${SecFossil}
    ${NSD_CreateLabel} 0 112u 100% 24u "$(AdvancedDownloadsHint)"
    Pop $0
    nsDialogs::Show
FunctionEnd

Function AdvancedDownloadsLeave
    ${NSD_GetText} $Handle_Winpython $WinpythonURL
    ${NSD_GetText} $Handle_VsCode $VsCodeURL
    ${NSD_GetText} $Handle_Git $GitURL
    ${NSD_GetText} $Handle_Fossil $FossilURL
    !insertmacro ValidateSetting ${SecWinPython} WinpythonURL
    !insertmacro ValidateSetting ${SecVsCode} VsCodeURL
    !insertmacro ValidateSetting ${SecGit} GitURL
    !insertmacro ValidateSetting ${SecFossil} FossilURL
FunctionEnd

Function AdvancedExtensionsPage
    ${If} $AdvancedOption != ${BST_CHECKED}
        Abort
    ${EndIf}
    ${IfNot} ${SectionIsSelected} ${SecVsCode}
        Abort
    ${EndIf}
    !insertmacro MUI_HEADER_TEXT "$(AdvancedExtensionsTitle)" "$(AdvancedExtensionsSubtitle)"
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    !insertmacro SettingRow "OCP CAD Viewer" OCP Handle_OCP 0 ${SecOCP}
    !insertmacro SettingRow "Python" VsCodePython Handle_VsCodePython 18 ${SecPythonExtension}
    !insertmacro SettingRow "Jupyter" Jupyter Handle_Jupyter 36 ${SecJupyter}
    !insertmacro SettingRow "Black Formatter" BlackFormatter Handle_BlackFormatter 54 ${SecBlack}
    !insertmacro SettingRow "Frame Indent Rainbow" FrameIndentRainbow Handle_FrameIndentRainbow 72 ${SecFrame}
    !insertmacro SettingRow "STL Viewer" STLviewer Handle_STLviewer 90 ${SecSTL}
    !insertmacro SettingRow "$(ComponentSvg)" SVGviewer Handle_SVGviewer 108 ${SecSVG}
    nsDialogs::Show
FunctionEnd

Function AdvancedExtensionsLeave
    ${NSD_GetText} $Handle_OCP $OCP
    ${NSD_GetText} $Handle_VsCodePython $VsCodePython
    ${NSD_GetText} $Handle_Jupyter $Jupyter
    ${NSD_GetText} $Handle_BlackFormatter $BlackFormatter
    ${NSD_GetText} $Handle_FrameIndentRainbow $FrameIndentRainbow
    ${NSD_GetText} $Handle_STLviewer $STLviewer
    ${NSD_GetText} $Handle_SVGviewer $SVGviewer
    !insertmacro ValidateSetting ${SecOCP} OCP
    !insertmacro ValidateSetting ${SecPythonExtension} VsCodePython
    !insertmacro ValidateSetting ${SecJupyter} Jupyter
    !insertmacro ValidateSetting ${SecBlack} BlackFormatter
    !insertmacro ValidateSetting ${SecFrame} FrameIndentRainbow
    !insertmacro ValidateSetting ${SecSTL} STLviewer
    !insertmacro ValidateSetting ${SecSVG} SVGviewer
    !insertmacro ValidateExtensionSetting ${SecOCP} OCP
    !insertmacro ValidateExtensionSetting ${SecPythonExtension} VsCodePython
    !insertmacro ValidateExtensionSetting ${SecJupyter} Jupyter
    !insertmacro ValidateExtensionSetting ${SecBlack} BlackFormatter
    !insertmacro ValidateExtensionSetting ${SecFrame} FrameIndentRainbow
    !insertmacro ValidateExtensionSetting ${SecSTL} STLviewer
    !insertmacro ValidateExtensionSetting ${SecSVG} SVGviewer
FunctionEnd

!macro OptionRow TEXT VARIABLE HANDLE Y
    ${NSD_CreateCheckBox} 0 ${Y}u 100% 12u "${TEXT}"
    Pop $${HANDLE}
    ${NSD_SetState} $${HANDLE} $${VARIABLE}
!macroend

Function OptionsPage
    !insertmacro MUI_HEADER_TEXT "$(OptionsTitle)" "$(OptionsSubtitle)"
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    !insertmacro OptionRow "$(ShortcutOption)" ShortcutOption Handle_Shortcut 0
    !insertmacro OptionRow "$(WorkspaceOption)" WorkspaceOption Handle_Workspace 24
    !insertmacro OptionRow "$(CleanupOption)" CleanupOption Handle_Cleanup 48
    !insertmacro OptionRow "$(AdvancedOptionText)" AdvancedOption Handle_Advanced 72
    # Options only apply when the editor was selected; never silently add an editor.
    ${IfNot} ${SectionIsSelected} ${SecVsCode}
        EnableWindow $Handle_Shortcut 0
        EnableWindow $Handle_Workspace 0
    ${EndIf}
    nsDialogs::Show
FunctionEnd

Function OptionsLeave
    ${NSD_GetState} $Handle_Shortcut $ShortcutOption
    ${NSD_GetState} $Handle_Workspace $WorkspaceOption
    ${NSD_GetState} $Handle_Cleanup $CleanupOption
    ${NSD_GetState} $Handle_Advanced $AdvancedOption
    Call NormalizeSelection
FunctionEnd
