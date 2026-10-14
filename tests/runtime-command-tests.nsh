# Mock executables are prepared by run_checks.py. Exercise the actual nsExec
# command quoting and exit-status handling without invoking pip or VS Code.
Function .onInit
    StrCpy $LANGUAGE ${LANG_ENGLISH}
    Call InitializeSettings
    StrCpy $INSTDIR "$EXEDIR\test output with spaces\combined"
    StrCpy $PyPath "WPy64-test"
    StrCpy $VsCodeINSTDIR "$INSTDIR\$PyPath\t\vscode"
    CreateDirectory "$INSTDIR\Downloads"
    CreateDirectory "$VsCodeINSTDIR\bin"
    StrCpy $PackageList "test-package"
    FileOpen $9 "$EXEDIR\command-test-results.txt" w
    FileWrite $9 "Starting package command$\r$\n"
    Call InstallPythonPackages
    FileWrite $9 "Package command returned: $0$\r$\n"
    StrCpy $ExtensionId "test.publisher"
    Call InstallExtension
    FileWrite $9 "Extension command returned: $0$\r$\n"
    FileClose $9
    SetErrorLevel 0
    Quit
FunctionEnd
