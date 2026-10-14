"""Compile and exercise the real NSIS selection/launcher code without downloads.

Usage: python tests/run_checks.py path/to/makensis.exe
Requires the same plugins as the production build. All artifacts stay in the
ignored .build-tools directory. Windows and Python 3 are required.
"""
from pathlib import Path
import json
import re
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / '.build-tools'


def run(*args):
    subprocess.run(args, cwd=ROOT, check=True, timeout=120)


def main():
    compiler = Path(sys.argv[1]).resolve()
    BUILD.mkdir(exist_ok=True)
    sources = [ROOT / 'Build123dPortableSetup.nsi', *sorted((ROOT / 'Installer').glob('*.nsh'))]
    refs = set(re.findall(r'\$\((\w+)\)', '\n'.join(p.read_text(encoding='utf-8-sig') for p in sources)))
    catalogs = []
    for name in ('English', 'German'):
        content = (ROOT / 'Languages' / f'{name}.nsh').read_text(encoding='utf-8-sig')
        rows = re.findall(r'^LangString (\w+) \$\{LANG_\w+\} "(.*)"$', content, re.M)
        catalog = dict(rows)
        assert len(rows) == len(catalog), f'Duplicate translations: {name}'
        assert set(catalog) == refs, f'Missing/unused translations: {name}, {refs ^ set(catalog)}'
        catalogs.append(catalog)
    for key in refs:
        placeholders = [re.findall(r'\$[A-Za-z0-9]+|%s', c[key]) for c in catalogs]
        assert placeholders[0] == placeholders[1], f'Translation placeholders differ: {key}'
    print(f'PASS: {len(refs)} English/German translation entries', flush=True)

    # The harness includes all real sections/functions. Replace only the entry
    # point and output filename, so tests Quit before payload sections execute.
    source = sources[0].read_text(encoding='utf-8-sig')
    source = source.replace('OutFile "PortableBuild123dSetup.exe"', 'OutFile ".build-tools\\InstallerTests.exe"')
    source = re.sub(r'Function \.onInit\n.*?\nFunctionEnd', '', source, flags=re.S)
    source += '\n!include "tests\\runtime-tests.nsh"\n'
    harness = BUILD / 'test-installer.nsi'
    harness.write_text(source, encoding='utf-8-sig')
    run(str(compiler), '/NOCD', '/V2', str(harness))
    run(str(BUILD / 'InstallerTests.exe'), '/S')
    result = (BUILD / 'test-results.txt').read_text(encoding='utf-8-sig')
    assert result.startswith('PASS:'), result
    print(result.strip(), flush=True)

    output = BUILD / 'test output with spaces'
    editor = output / 'editor only'
    combined = output / 'combined' / 'WPy64-test'
    for directory in (editor, combined / 't' / 'vscode'):
        launcher = (directory / 'VsCode.cmd').read_text()
        assert '%~dp0Code.exe' in launcher
        assert '%~dp0data\\GitPortable\\bin' in launcher
        assert '%~dp0data\\Fossil' in launcher
        assert str(ROOT) not in launcher, 'Launcher contains absolute build paths'
    assert '..\\..\\scripts\\env_for_icons.bat' in (combined / 't' / 'vscode' / 'VsCode.cmd').read_text()
    assert 'env_for_icons' not in (editor / 'VsCode.cmd').read_text()
    settings = combined / 't' / 'vscode' / 'data' / 'user-data' / 'User' / 'settings.json'
    assert json.loads(settings.read_text()) == {'existing': True}
    assert not (combined.parent / 'Downloads').exists()
    print('PASS: portable paths and existing settings preserved', flush=True)

    # A silent mock editor records the environment received through the real
    # generated batch scripts. Exercise them after copying the installation.
    mock_source = BUILD / 'mock-code.nsi'
    mock_source.write_text(r'''
Unicode True
Name "Launcher test editor"
OutFile ".build-tools\MockCode.exe"
RequestExecutionLevel user
SilentInstall silent
Function .onInit
    FileOpen $1 "$EXEDIR\mock-code-result.tmp" w
    ReadEnvStr $0 TEST_PYTHON_ENV
    FileWrite $1 "ENV=$0$\r$\n"
    ; The host PATH can exceed NSIS's string limit. Search the full Windows
    ; environment buffer rather than truncating it through ReadEnvStr.
    System::Alloc 65536
    Pop $2
    System::Call 'kernel32::GetEnvironmentVariableW(w "PATH", p r2, i 32768) i.r0'
    System::Call 'shlwapi::StrStrIW(p r2, w "$EXEDIR\data\GitPortable\bin") p.r0'
    IntCmp $0 0 +2
    StrCpy $0 1
    FileWrite $1 "GIT=$0$\r$\n"
    System::Call 'shlwapi::StrStrIW(p r2, w "$EXEDIR\data\Fossil") p.r0'
    IntCmp $0 0 +2
    StrCpy $0 1
    FileWrite $1 "FOSSIL=$0$\r$\n"
    System::Free $2
    FileWrite $1 "ARGS=$CMDLINE$\r$\n"
    FileClose $1
    Delete "$EXEDIR\mock-code-result.txt"
    Rename "$EXEDIR\mock-code-result.tmp" "$EXEDIR\mock-code-result.txt"
    SetErrorLevel 0
    Quit
FunctionEnd
Section
SectionEnd
''', encoding='utf-8')
    run(str(compiler), '/NOCD', '/V2', str(mock_source))
    relocated = BUILD / 'relocated output with spaces'
    shutil.copytree(output, relocated, dirs_exist_ok=True)
    for name, environment in [('editor only', ''), ('combined/WPy64-test/t/vscode', 'loaded')]:
        directory = relocated / name
        shutil.copyfile(BUILD / 'MockCode.exe', directory / 'Code.exe')
        for launcher in [directory / 'VsCode.cmd',
                         (directory if not environment else directory.parents[1]) / 'ThumbdriveAdjust.cmd']:
            marker = directory / 'mock-code-result.txt'
            marker.unlink(missing_ok=True)
            # Python's list quoting follows the C runtime, while cmd.exe uses
            # different quote rules. Supply its /S /C command line directly.
            subprocess.run(f'cmd.exe /D /S /C ""{launcher}" "sample file.py""',
                           cwd=ROOT, check=True, timeout=30)
            deadline = time.monotonic() + 10
            while not marker.exists() and time.monotonic() < deadline:
                time.sleep(0.1)
            content = marker.read_text()
            assert f'ENV={environment}\n' in content, content
            assert 'GIT=1\n' in content, content
            assert 'FOSSIL=1\n' in content, content
            assert '"sample file.py"' in content, content
    print('PASS: relocated launchers execute with spaces, arguments, Python environment and version-control PATH', flush=True)

    # Use a mock python.exe and Code.cmd to exercise the production nsExec
    # commands, including their quoting and exit-code handling.
    scripts = combined / 'scripts'
    shutil.copyfile(BUILD / 'MockCode.exe', scripts / 'python.exe')
    (scripts / 'env_for_icons.bat').write_text(
        '@echo off\nset "TEST_PYTHON_ENV=loaded"\nset "PATH=%~dp0;%PATH%"\n', newline='\r\n')
    bin_dir = combined / 't' / 'vscode' / 'bin'
    bin_dir.mkdir(exist_ok=True)
    (bin_dir / 'Code.cmd').write_text(
        '@echo off\necho %*>"%~dp0extension-arguments.txt"\nexit /b 0\n', newline='\r\n')
    command_source = source.replace('InstallerTests.exe', 'CommandTests.exe').replace(
        'tests\\runtime-tests.nsh', 'tests\\runtime-command-tests.nsh')
    command_harness = BUILD / 'command-tests.nsi'
    command_harness.write_text(command_source, encoding='utf-8-sig')
    run(str(compiler), '/NOCD', '/V2', str(command_harness))
    run(str(BUILD / 'CommandTests.exe'), '/S')
    assert '-m pip install test-package' in (scripts / 'mock-code-result.txt').read_text()
    assert '--install-extension "test.publisher"' in (bin_dir / 'extension-arguments.txt').read_text()
    print('PASS: production pip and extension commands execute against mocks in paths with spaces', flush=True)


if __name__ == '__main__':
    main()
