# Fail the installation immediately rather than letting dependent sections run
# against a missing runtime/editor. The details log keeps subprocess output.
!macro OpenOutput PATH
    ClearErrors
    FileOpen $R1 "${PATH}" w
    ${If} ${Errors}
        MessageBox MB_OK|MB_ICONSTOP "$(WriteFileFailed) ${PATH}" /SD IDOK
        Abort
    ${EndIf}
!macroend

!macro CloseOutput
    FileClose $R1
    ${If} ${Errors}
        MessageBox MB_OK|MB_ICONSTOP "$(WriteFileFailed)" /SD IDOK
        Abort
    ${EndIf}
!macroend

!macro CheckDirectory PATH
    ClearErrors
    CreateDirectory "${PATH}"
    ${If} ${Errors}
        MessageBox MB_OK|MB_ICONSTOP "$(CreateDirectoryFailed) ${PATH}" /SD IDOK
        Abort
    ${EndIf}
!macroend

!macro Download URL FILE ERRORSTRING
    inetc::get "${URL}" "$INSTDIR\Downloads\${FILE}" /END
    Pop $0
    ${If} $0 != "OK"
        MessageBox MB_OK|MB_ICONSTOP "${ERRORSTRING}" /SD IDOK
        Abort
    ${EndIf}
!macroend

Function InstallWinPython
    !insertmacro Download $WinpythonURL "Winpython.exe" "$(WinPythonDownloadFailed)"
    SetOutPath "$INSTDIR"
    ClearErrors
    Nsis7z::ExtractWithDetails "$INSTDIR\Downloads\Winpython.exe" "$(ExtractWinPython)"
    ${If} ${Errors}
        MessageBox MB_OK|MB_ICONSTOP "$(WinPythonExtractFailed)" /SD IDOK
        Abort
    ${EndIf}
    # Locate the runtime by its env script, checking directory results only.
    StrCpy $PyPath ""
    FindFirst $0 $1 "$INSTDIR\WPy64*"
    ${DoWhile} $1 != ""
        IfFileExists "$INSTDIR\$1\scripts\env_for_icons.bat" 0 next_python
        ${If} $PyPath != ""
            FindClose $0
            MessageBox MB_OK|MB_ICONSTOP "$(MultiplePythonEnvironments)" /SD IDOK
            Abort
        ${EndIf}
        StrCpy $PyPath $1
        next_python:
        FindNext $0 $1
    ${Loop}
    FindClose $0
    ${If} $PyPath == ""
        MessageBox MB_OK|MB_ICONSTOP "$(WinPythonExtractFailed)" /SD IDOK
        Abort
    ${EndIf}
    StrCpy $VsCodeINSTDIR "$INSTDIR\$PyPath\t\vscode"
FunctionEnd

Function InstallPythonPackages
    DetailPrint "$(InstallPythonPackages) $PackageList"
    !insertmacro OpenOutput "$INSTDIR\Downloads\InstallPackages.cmd"
    FileWrite $R1 '@echo off$\r$\n'
    FileWrite $R1 'call "$INSTDIR\$PyPath\scripts\env_for_icons.bat"$\r$\n'
    FileWrite $R1 'if errorlevel 1 exit /b %errorlevel%$\r$\n'
    FileWrite $R1 'python -m pip install $PackageList$\r$\n'
    FileWrite $R1 'exit /b %errorlevel%$\r$\n'
    !insertmacro CloseOutput
    # /c terminates when finished; /k kept the previous installer waiting forever.
    nsExec::ExecToLog '"$SYSDIR\cmd.exe" /D /C ""$INSTDIR\Downloads\InstallPackages.cmd""'
    Pop $0
    ${If} $0 != "0"
        MessageBox MB_OK|MB_ICONSTOP "$(PackagesFailed)" /SD IDOK
        Abort
    ${EndIf}
FunctionEnd

Function InstallVsCode
    !insertmacro Download $VsCodeURL "VsCode.zip" "$(VsCodeDownloadFailed)"
    !insertmacro CheckDirectory "$VsCodeINSTDIR"
    ClearErrors
    nsisunz::UnzipToStack "$INSTDIR\Downloads\VsCode.zip" "$VsCodeINSTDIR"
    Pop $0
    ${If} $0 != "success"
        MessageBox MB_OK|MB_ICONSTOP "$(VsCodeUnzipFailed)" /SD IDOK
        Abort
    ${EndIf}
    IfFileExists "$VsCodeINSTDIR\Code.exe" +3 0
        MessageBox MB_OK|MB_ICONSTOP "$(VsCodeUnzipFailed)" /SD IDOK
        Abort
    DetailPrint "$(CreateVsCodeData)"
    !insertmacro CheckDirectory "$VsCodeINSTDIR\data\user-data\User"
    !insertmacro CheckDirectory "$VsCodeINSTDIR\data\tmp"
FunctionEnd

Function InstallGit
    !insertmacro Download $GitURL "Git.exe" "$(GitDownloadFailed)"
    !insertmacro CheckDirectory "$VsCodeINSTDIR\data\GitPortable"
    SetOutPath "$VsCodeINSTDIR\data\GitPortable"
    ClearErrors
    Nsis7z::ExtractWithDetails "$INSTDIR\Downloads\Git.exe" "$(ExtractGit)"
    ${If} ${Errors}
        MessageBox MB_OK|MB_ICONSTOP "$(GitUnzipFailed)" /SD IDOK
        Abort
    ${EndIf}
    IfFileExists "$VsCodeINSTDIR\data\GitPortable\bin\git.exe" +3 0
        MessageBox MB_OK|MB_ICONSTOP "$(GitUnzipFailed)" /SD IDOK
        Abort
FunctionEnd

Function InstallFossil
    !insertmacro Download $FossilURL "Fossil.zip" "$(FossilDownloadFailed)"
    !insertmacro CheckDirectory "$VsCodeINSTDIR\data\Fossil"
    ClearErrors
    nsisunz::UnzipToStack "$INSTDIR\Downloads\Fossil.zip" "$VsCodeINSTDIR\data\Fossil"
    Pop $0
    ${If} $0 != "success"
        MessageBox MB_OK|MB_ICONSTOP "$(FossilUnzipFailed)" /SD IDOK
        Abort
    ${EndIf}
    IfFileExists "$VsCodeINSTDIR\data\Fossil\fossil.exe" +3 0
        MessageBox MB_OK|MB_ICONSTOP "$(FossilUnzipFailed)" /SD IDOK
        Abort
FunctionEnd

Function InstallExtension
    Call ValidateExtensionId
    DetailPrint "$(InstallExtension) $ExtensionId"
    SetOutPath "$VsCodeINSTDIR\bin"
    nsExec::ExecToLog '"$SYSDIR\cmd.exe" /D /C ""$VsCodeINSTDIR\bin\Code.cmd" --install-extension "$ExtensionId""'
    Pop $0
    ${If} $0 != "0"
        MessageBox MB_OK|MB_ICONSTOP "$(ExtensionFailed)" /SD IDOK
        Abort
    ${EndIf}
FunctionEnd

Function ValidateExtensionId
    # Marketplace IDs are passed to cmd.exe: reject shell syntax and quotes.
    StrLen $1 $ExtensionId
    System::Call 'shlwapi::StrSpnW(w "$ExtensionId", w "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-") i .r0'
    ${If} $1 == 0
    ${OrIf} $0 != $1
        MessageBox MB_OK|MB_ICONEXCLAMATION "$(InvalidExtensionId)" /SD IDOK
        Abort
    ${EndIf}
FunctionEnd

# Always generate the launcher when VS Code is installed. Relative paths remain
# valid after moving the environment and desktop shortcuts have a valid target.
Function CreateLauncher
    DetailPrint "$(CreateLauncher)"
    !insertmacro OpenOutput "$VsCodeINSTDIR\VsCode.cmd"
    FileWrite $R1 '@echo off$\r$\nsetlocal$\r$\n'
    ${If} ${SectionIsSelected} ${SecWinPython}
        FileWrite $R1 'call "%~dp0..\..\scripts\env_for_icons.bat"$\r$\n'
    ${EndIf}
    FileWrite $R1 'set "PATH=%PATH%'
    ${If} ${SectionIsSelected} ${SecGit}
        FileWrite $R1 ';%~dp0data\GitPortable\bin'
    ${EndIf}
    ${If} ${SectionIsSelected} ${SecFossil}
        FileWrite $R1 ';%~dp0data\Fossil'
    ${EndIf}
    FileWrite $R1 '"$\r$\nstart "" "%~dp0Code.exe" %*$\r$\n'
    !insertmacro CloseOutput
FunctionEnd

Function CreateThumbdriveScript
    DetailPrint "$(CreateThumbdriveScript)"
    ${If} ${SectionIsSelected} ${SecWinPython}
        StrCpy $HelperDirectory "$INSTDIR\$PyPath"
    ${Else}
        StrCpy $HelperDirectory "$VsCodeINSTDIR"
    ${EndIf}
    !insertmacro OpenOutput "$HelperDirectory\ThumbdriveAdjust.cmd"
    # Launchers already use relative paths. No rewriting of winpython.ini needed.
    FileWrite $R1 '@echo off$\r$\n'
    ${If} ${SectionIsSelected} ${SecWinPython}
        FileWrite $R1 'call "%~dp0t\vscode\VsCode.cmd" %*$\r$\n'
    ${Else}
        FileWrite $R1 'call "%~dp0VsCode.cmd" %*$\r$\n'
    ${EndIf}
    !insertmacro CloseOutput
FunctionEnd

Function FinalizeInstallation
    ${If} ${SectionIsSelected} ${SecVsCode}
        Call CreateLauncher
        ${If} $WorkspaceOption == ${BST_CHECKED}
            # Never append a second JSON object to existing user settings.
            IfFileExists "$VsCodeINSTDIR\data\user-data\User\settings.json" workspace_exists
            DetailPrint "$(AdjustWorkspace)"
            !insertmacro OpenOutput "$VsCodeINSTDIR\data\user-data\User\settings.json"
            FileWrite $R1 '{$\r$\n'
            FileWrite $R1 '  "security.workspace.trust.untrustedFiles": "open",$\r$\n'
            FileWrite $R1 '  "workbench.colorCustomizations": {$\r$\n'
            FileWrite $R1 '    "editor.lineHighlightBackground": "#ffffff36",$\r$\n'
            FileWrite $R1 '    "editor.lineHighlightBorder": "#ffff00"$\r$\n'
            FileWrite $R1 '  }$\r$\n}$\r$\n'
            !insertmacro CloseOutput
            Goto workspace_done
            workspace_exists:
            DetailPrint "$(WorkspacePreserved)"
            workspace_done:
        ${EndIf}
        ${If} $ShortcutOption == ${BST_CHECKED}
            ClearErrors
            CreateShortcut "$DESKTOP\Portable Build123d.lnk" "$VsCodeINSTDIR\VsCode.cmd" "" "$VsCodeINSTDIR\Code.exe"
            ${If} ${Errors}
                MessageBox MB_OK|MB_ICONSTOP "$(ShortcutFailed)" /SD IDOK
                Abort
            ${EndIf}
        ${EndIf}
    ${EndIf}
    # Move away from Downloads before removing it. Cleanup is only on success.
    SetOutPath "$INSTDIR"
    ${If} $CleanupOption == ${BST_CHECKED}
        ClearErrors
        RMDir /r "$INSTDIR\Downloads"
        ${If} ${Errors}
            DetailPrint "$(CleanupFailed)"
        ${EndIf}
    ${EndIf}
FunctionEnd
