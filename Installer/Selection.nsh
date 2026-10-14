# Mark prerequisites selected and read-only while dependent components are selected.
# Recompute locks each time so deselecting dependents makes prerequisites editable.
!macro Unlock SECTION
    SectionGetFlags ${SECTION} $R0
    IntOp $R0 $R0 & 0xFFFFFFEF
    SectionSetFlags ${SECTION} $R0
!macroend

!macro Require DEPENDENT PREREQUISITE
    ${If} ${SectionIsSelected} ${DEPENDENT}
        SectionGetFlags ${PREREQUISITE} $R0
        IntOp $R0 $R0 | ${SF_SELECTED}
        IntOp $R0 $R0 | ${SF_RO}
        SectionSetFlags ${PREREQUISITE} $R0
    ${EndIf}
!macroend

Function NormalizeSelection
    Push $R0
    !insertmacro Unlock ${SecWinPython}
    !insertmacro Unlock ${SecPackages}
    !insertmacro Unlock ${SecVsCode}
    !insertmacro Unlock ${SecPythonExtension}
    # Process dependents before prerequisites to resolve the entire chain in one pass.
    !insertmacro Require ${SecOCP} ${SecPackages}
    !insertmacro Require ${SecOCP} ${SecPythonExtension}
    !insertmacro Require ${SecCadquery} ${SecWinPython}
    !insertmacro Require ${SecPackages} ${SecWinPython}
    !insertmacro Require ${SecPythonExtension} ${SecVsCode}
    !insertmacro Require ${SecOCP} ${SecVsCode}
    !insertmacro Require ${SecJupyter} ${SecVsCode}
    !insertmacro Require ${SecBlack} ${SecVsCode}
    !insertmacro Require ${SecFrame} ${SecVsCode}
    !insertmacro Require ${SecSTL} ${SecVsCode}
    !insertmacro Require ${SecSVG} ${SecVsCode}
    !insertmacro Require ${SecGit} ${SecVsCode}
    !insertmacro Require ${SecFossil} ${SecVsCode}
    !insertmacro Require ${SecLaunchers} ${SecVsCode}
    !insertmacro Require ${SecSnippets} ${SecVsCode}
    ${If} $WorkspaceOption == ${BST_CHECKED}
    ${OrIf} $ShortcutOption == ${BST_CHECKED}
        SectionGetFlags ${SecVsCode} $R0
        IntOp $R0 $R0 | ${SF_SELECTED}
        IntOp $R0 $R0 | ${SF_RO}
        SectionSetFlags ${SecVsCode} $R0
    ${EndIf}
    Pop $R0
FunctionEnd

Function .onSelChange
    ${If} $0 == -1
        Push $R0
        GetCurInstType $R0
        Push $R0
        Call ApplyPreset
        Pop $R0
    ${EndIf}
    Call NormalizeSelection
FunctionEnd

# SetCurInstType alone sets the preset index; apply its section membership
# explicitly, including during .onInit before the components page exists.
Function ApplyPreset
    Exch $R2
    Push $R0
    Push $R1
    Push $R3
    ${If} $R2 < 2
        IntOp $R2 1 << $R2
        StrCpy $R3 ${SecWinPython}
        ${DoWhile} $R3 <= ${SecSnippets}
            SectionGetFlags $R3 $R0
            IntOp $R0 $R0 & ${SECTION_OFF}
            IntOp $R0 $R0 & 0xFFFFFFEF
            SectionGetInstTypes $R3 $R1
            IntOp $R1 $R1 & $R2
            ${If} $R1 != 0
                IntOp $R0 $R0 | ${SF_SELECTED}
            ${EndIf}
            SectionSetFlags $R3 $R0
            IntOp $R3 $R3 + 1
        ${Loop}
    ${EndIf}
    Pop $R3
    Pop $R1
    Pop $R0
    Pop $R2
FunctionEnd

Function ComponentsLeave
    Call NormalizeSelection
    # At least one payload is required; optional children have already selected theirs.
    ${IfNot} ${SectionIsSelected} ${SecWinPython}
    ${AndIfNot} ${SectionIsSelected} ${SecVsCode}
        MessageBox MB_OK|MB_ICONEXCLAMATION "$(SelectPayload)" /SD IDOK
        Abort
    ${EndIf}
FunctionEnd
