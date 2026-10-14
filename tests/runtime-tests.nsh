# Compiled together with the real installer by run_checks.py. Tests run during
# .onInit and Quit before any download/installation section can execute.
!macro AssertSelected SECTION EXPECTED
    SectionGetFlags ${SECTION} $0
    IntOp $0 $0 & ${SF_SELECTED}
    ${If} $0 != ${EXPECTED}
        FileWrite $9 "FAIL: ${SECTION} selection, expected ${EXPECTED}, got $0$\r$\n"
        FileClose $9
        SetErrorLevel 1
        Quit
    ${EndIf}
!macroend

!macro AssertLocked SECTION EXPECTED
    SectionGetFlags ${SECTION} $0
    IntOp $0 $0 & ${SF_RO}
    ${If} $0 != ${EXPECTED}
        FileWrite $9 "FAIL: ${SECTION} lock, expected ${EXPECTED}, got $0$\r$\n"
        FileClose $9
        SetErrorLevel 1
        Quit
    ${EndIf}
!macroend

!macro ResetSelection
    StrCpy $WorkspaceOption ${BST_UNCHECKED}
    StrCpy $ShortcutOption ${BST_UNCHECKED}
    StrCpy $2 ${SecWinPython}
    ${DoWhile} $2 <= ${SecSnippets}
        SectionGetFlags $2 $0
        IntOp $0 $0 & ${SECTION_OFF}
        IntOp $0 $0 & 0xFFFFFFEF
        SectionSetFlags $2 $0
        IntOp $2 $2 + 1
    ${Loop}
!macroend

!macro TestEditorDependency SECTION
    !insertmacro ResetSelection
    !insertmacro SelectSection ${SECTION}
    Call NormalizeSelection
    !insertmacro AssertSelected ${SecVsCode} 1
    !insertmacro AssertLocked ${SecVsCode} 16
!macroend

Function .onInit
    StrCpy $LANGUAGE ${LANG_ENGLISH}
    Call InitializeSettings
    FileOpen $9 "$EXEDIR\test-results.txt" w
    SetCurInstType 0
    Push 0
    Call ApplyPreset
    Call NormalizeSelection
    !insertmacro AssertSelected ${SecWinPython} 1
    !insertmacro AssertSelected ${SecPackages} 1
    !insertmacro AssertSelected ${SecVsCode} 1
    !insertmacro AssertSelected ${SecPythonExtension} 1
    !insertmacro AssertSelected ${SecOCP} 1
    !insertmacro AssertSelected ${SecJupyter} 1
    !insertmacro AssertSelected ${SecGit} 0
    !insertmacro AssertSelected ${SecFossil} 0
    !insertmacro AssertSelected ${SecCadquery} 0
    !insertmacro AssertSelected ${SecLaunchers} 0
    !insertmacro AssertSelected ${SecSnippets} 0
    # Switching presets must release dependencies inherited from the previous one.
    SetCurInstType 1
    Push 1
    Call ApplyPreset
    Call NormalizeSelection
    !insertmacro AssertSelected ${SecWinPython} 0
    !insertmacro AssertSelected ${SecPackages} 0
    !insertmacro AssertSelected ${SecPythonExtension} 0
    !insertmacro AssertSelected ${SecOCP} 0
    !insertmacro AssertSelected ${SecJupyter} 0
    !insertmacro AssertSelected ${SecVsCode} 1
    !insertmacro AssertLocked ${SecVsCode} 0
    !insertmacro AssertLocked ${SecWinPython} 0

    !insertmacro TestEditorDependency ${SecPythonExtension}
    !insertmacro TestEditorDependency ${SecOCP}
    !insertmacro AssertSelected ${SecPackages} 1
    !insertmacro AssertSelected ${SecWinPython} 1
    !insertmacro AssertSelected ${SecPythonExtension} 1
    !insertmacro AssertLocked ${SecPackages} 16
    !insertmacro AssertLocked ${SecWinPython} 16
    !insertmacro AssertLocked ${SecPythonExtension} 16
    !insertmacro TestEditorDependency ${SecJupyter}
    !insertmacro TestEditorDependency ${SecBlack}
    !insertmacro TestEditorDependency ${SecFrame}
    !insertmacro TestEditorDependency ${SecSTL}
    !insertmacro TestEditorDependency ${SecSVG}
    !insertmacro TestEditorDependency ${SecGit}
    !insertmacro TestEditorDependency ${SecFossil}
    !insertmacro TestEditorDependency ${SecLaunchers}
    !insertmacro TestEditorDependency ${SecSnippets}
    !insertmacro ResetSelection
    !insertmacro SelectSection ${SecCadquery}
    Call NormalizeSelection
    !insertmacro AssertSelected ${SecWinPython} 1
    !insertmacro AssertSelected ${SecVsCode} 0
    !insertmacro AssertLocked ${SecWinPython} 16
    !insertmacro UnselectSection ${SecCadquery}
    Call NormalizeSelection
    !insertmacro AssertLocked ${SecWinPython} 0
    !insertmacro ResetSelection
    !insertmacro SelectSection ${SecPackages}
    Call NormalizeSelection
    !insertmacro AssertSelected ${SecWinPython} 1
    !insertmacro AssertSelected ${SecVsCode} 0

    !insertmacro ResetSelection
    StrCpy $WorkspaceOption ${BST_CHECKED}
    Call NormalizeSelection
    !insertmacro AssertSelected ${SecVsCode} 1
    !insertmacro AssertLocked ${SecVsCode} 16
    StrCpy $WorkspaceOption ${BST_UNCHECKED}
    Call NormalizeSelection
    !insertmacro AssertLocked ${SecVsCode} 0
    !insertmacro ResetSelection
    StrCpy $ShortcutOption ${BST_CHECKED}
    Call NormalizeSelection
    !insertmacro AssertSelected ${SecVsCode} 1

    # Generate real launchers in paths containing spaces for both supported layouts.
    !insertmacro ResetSelection
    !insertmacro SelectSection ${SecVsCode}
    !insertmacro SelectSection ${SecGit}
    !insertmacro SelectSection ${SecFossil}
    StrCpy $INSTDIR "$EXEDIR\test output with spaces\editor only"
    StrCpy $VsCodeINSTDIR "$INSTDIR"
    CreateDirectory "$VsCodeINSTDIR"
    Call CreateLauncher
    Call CreateThumbdriveScript

    !insertmacro SelectSection ${SecWinPython}
    StrCpy $INSTDIR "$EXEDIR\test output with spaces\combined"
    StrCpy $PyPath "WPy64-test"
    StrCpy $VsCodeINSTDIR "$INSTDIR\$PyPath\t\vscode"
    CreateDirectory "$VsCodeINSTDIR"
    CreateDirectory "$INSTDIR\$PyPath\scripts"
    # Mock the environment script to prove call/return and PATH propagation.
    FileOpen $R1 "$INSTDIR\$PyPath\scripts\env_for_icons.bat" w
    FileWrite $R1 '@echo off$\r$\nset "TEST_PYTHON_ENV=loaded"$\r$\n'
    FileClose $R1
    Call CreateLauncher
    Call CreateThumbdriveScript

    # Existing settings must survive optional workspace customization unchanged.
    CreateDirectory "$VsCodeINSTDIR\data\user-data\User"
    FileOpen $R1 "$VsCodeINSTDIR\data\user-data\User\settings.json" w
    FileWrite $R1 '{"existing":true}'
    FileClose $R1
    CreateDirectory "$INSTDIR\Downloads"
    FileOpen $R1 "$INSTDIR\Downloads\test.txt" w
    FileWrite $R1 'download artifact'
    FileClose $R1
    StrCpy $WorkspaceOption ${BST_CHECKED}
    StrCpy $ShortcutOption ${BST_UNCHECKED}
    StrCpy $CleanupOption ${BST_CHECKED}
    Call FinalizeInstallation
    IfFileExists "$INSTDIR\Downloads\test.txt" cleanup_failed
    FileWrite $9 "PASS: presets, dependencies, locks, launcher generation, settings preservation and cleanup$\r$\n"
    FileClose $9
    SetErrorLevel 0
    Quit
    cleanup_failed:
    FileWrite $9 "FAIL: cleanup left downloaded file$\r$\n"
    FileClose $9
    SetErrorLevel 1
    Quit
FunctionEnd
