Function InitializeSettings
    # Initialize once; Back/Next navigation must preserve edits and options.
    StrCpy $WinpythonURL "https://github.com/winpython/winpython/releases/download/17.12.20260522%2FWinPython/WinPython64-3.13.15.0dot.exe"
    StrCpy $VsCodeURL "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
    StrCpy $GitURL "https://github.com/git-for-windows/git/releases/download/v2.56.0.windows.2/PortableGit-2.56.0.2-64-bit.7z.exe"
    StrCpy $FossilURL "https://www.fossil-scm.org/home/uv/fossil-w64-2.24.zip"
    StrCpy $OCP "bernhard-42.ocp-cad-viewer"
    StrCpy $VsCodePython "ms-python.python"
    StrCpy $Jupyter "ms-toolsai.jupyter"
    StrCpy $BlackFormatter "ms-python.black-formatter"
    StrCpy $FrameIndentRainbow "firejump.frame-indent-rainbow"
    StrCpy $STLviewer "mtsmfm.vscode-stl-viewer"
    StrCpy $SVGviewer "simonsiefke.svg-preview"
    StrCpy $WorkspaceOption ${BST_UNCHECKED}
    StrCpy $ShortcutOption ${BST_UNCHECKED}
    StrCpy $CleanupOption ${BST_CHECKED}
    StrCpy $AdvancedOption ${BST_UNCHECKED}
FunctionEnd
