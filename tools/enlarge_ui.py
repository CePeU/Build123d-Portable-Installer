"""Generate a larger native NSIS UI, retaining the installed NSIS resources.

All dialog and control coordinates grow by 40%; fonts retain their normal size.
The components tree doubles its enlarged width. Its description spans the page
above the installation-type selector.
Runs on Windows with Python 3, invoked automatically by the installer script.
"""
import ctypes as C
from ctypes import wintypes as W
from pathlib import Path
import shutil
import struct
import sys
import math

# An additional 20% of the enlarged wizard height, assigned to page content.
# Further tree height in dialog units: 9 is approximately 5% of its previous 172.
TREE_EXTRA_HEIGHT = 20
EXTRA_HEIGHT = round(round(222 * 1.4) * 0.20) + TREE_EXTRA_HEIGHT

def enlarge_dialog(raw):
    data = bytearray(raw)
    extended = struct.unpack_from('<HH', data) == (1, 0xffff)
    style_offset, count_offset, rect_offset = (12, 16, 18) if extended else (0, 8, 10)
    style = struct.unpack_from('<I', data, style_offset)[0]
    count = struct.unpack_from('<H', data, count_offset)[0]

    def resize(offset):
        values = struct.unpack_from('<hhhh', data, offset)
        struct.pack_into('<hhhh', data, offset, *(round(v * 1.4) for v in values))

    def skip_string(offset):
        word = struct.unpack_from('<H', data, offset)[0]
        if word == 0xffff:
            return offset + 4
        while struct.unpack_from('<H', data, offset)[0]:
            offset += 2
        return offset + 2

    resize(rect_offset)
    pos = rect_offset + 8
    for _ in range(3):  # menu, window class, title
        pos = skip_string(pos)
    if style & 0x40:  # DS_SETFONT
        pos += 6 if extended else 2
        pos = skip_string(pos)
    controls = {}
    for _ in range(count):
        pos = (pos + 3) & ~3
        rect = pos + (12 if extended else 8)
        control_id = struct.unpack_from('<I' if extended else '<H', data,
                                        pos + (20 if extended else 16))[0]
        controls[control_id] = rect
        resize(rect)
        pos += 24 if extended else 18
        pos = skip_string(pos)  # class
        pos = skip_string(pos)  # title
        extra = struct.unpack_from('<H', data, pos)[0]
        pos += extra if extra else 2
    x, y, dialog_width, dialog_height = struct.unpack_from('<hhhh', data, rect_offset)
    if 1018 in controls:  # Outer wizard: grow content, move footer/buttons down.
        struct.pack_into('<hhhh', data, rect_offset, x, y, dialog_width,
                         dialog_height + EXTRA_HEIGHT)
        for control_id, offset in controls.items():
            cx, cy, width, height = struct.unpack_from('<hhhh', data, offset)
            if control_id in (1018, 1044):
                height += EXTRA_HEIGHT
            elif control_id in (1, 2, 3, 1035, 1045, 1256, 1028):
                cy += EXTRA_HEIGHT
            struct.pack_into('<hhhh', data, offset, cx, cy, width, height)
    elif dialog_width == 420 and dialog_height == 196:
        # Standard child pages fill the larger content area.
        struct.pack_into('<hhhh', data, rect_offset, x, y, dialog_width,
                         dialog_height + EXTRA_HEIGHT)
    if 1032 in controls:  # Components tree; only present on the components page.
        tree_width = struct.unpack_from('<hhhh', data, controls[1032])[2]
        left = math.floor((tree_width * 0.35))
        for control_id, offset in controls.items():
            x, y, width, height = struct.unpack_from('<hhhh', data, offset)
            if control_id in (1032, 1017):  # Tree and preset selector stay aligned.
                x -= left
                width += tree_width
            elif control_id in (1021, 1022, 1023):
                width -= left
            struct.pack_into('<hhhh', data, offset, x, y, width, height)
        page_width = struct.unpack_from('<hhhh', data, rect_offset)[2]

        def place(control_id, x, y, width, height):
            struct.pack_into('<hhhh', data, controls[control_id], x, y, width, height)

        # Control 1006 contains the standard component-selection instructions.
        # Keep them visible above the description and installation-type selector.
        place(1006, 0, 0, page_width, 20)
        place(1042, 0, 22, page_width, 32)
        place(1043, 7, 34, page_width - 14, 18)
        for control_id, new_y in ((1017, 58), (1021, 60), (1032, 79), (1022, 79)):
            offset = controls[control_id]
            x, y, width, height = struct.unpack_from('<hhhh', data, offset)
            # Give all additional vertical room to the tree/instruction column.
            if control_id in (1032, 1022):
                height += EXTRA_HEIGHT - (new_y - y)
            place(control_id, x, new_y, width, height)
        offset = controls[1023]
        x, y, width, height = struct.unpack_from('<hhhh', data, offset)
        place(1023, x, y + EXTRA_HEIGHT, width, height)
    return bytes(data)


def main():
    source, target = map(Path, sys.argv[1:])
    target.parent.mkdir(parents=True, exist_ok=True)
    kernel = C.WinDLL('kernel32', use_last_error=True)
    kernel.LoadLibraryExW.argtypes = [W.LPCWSTR, W.HANDLE, W.DWORD]
    kernel.LoadLibraryExW.restype = W.HMODULE
    kernel.FindResourceW.argtypes = [W.HMODULE, C.c_void_p, C.c_void_p]
    kernel.FindResourceW.restype = W.HANDLE
    kernel.SizeofResource.argtypes = [W.HMODULE, W.HANDLE]
    kernel.SizeofResource.restype = W.DWORD
    kernel.LoadResource.argtypes = [W.HMODULE, W.HANDLE]
    kernel.LoadResource.restype = W.HANDLE
    kernel.LockResource.argtypes = [W.HANDLE]
    kernel.LockResource.restype = C.c_void_p
    kernel.FreeLibrary.argtypes = [W.HMODULE]
    kernel.BeginUpdateResourceW.argtypes = [W.LPCWSTR, W.BOOL]
    kernel.BeginUpdateResourceW.restype = W.HANDLE
    kernel.UpdateResourceW.argtypes = [W.HANDLE, C.c_void_p, C.c_void_p, W.WORD, C.c_void_p, W.DWORD]
    kernel.EndUpdateResourceW.argtypes = [W.HANDLE, W.BOOL]
    callback_type = C.WINFUNCTYPE(W.BOOL, W.HMODULE, C.c_void_p, C.c_void_p, W.LPARAM)
    kernel.EnumResourceNamesW.argtypes = [W.HMODULE, C.c_void_p, callback_type, W.LPARAM]
    module = kernel.LoadLibraryExW(str(source), None, 2)
    if not module:
        raise C.WinError(C.get_last_error())
    dialogs = []
    errors = []

    @callback_type
    def collect(module, kind, name, context):
        try:
            resource = kernel.FindResourceW(module, name, kind)
            if not resource:
                raise C.WinError(C.get_last_error())
            size = kernel.SizeofResource(module, resource)
            pointer = kernel.LockResource(kernel.LoadResource(module, resource))
            dialogs.append((name, enlarge_dialog(C.string_at(pointer, size))))
            return True
        except Exception as error:
            errors.append(error)
            return False

    try:
        if not kernel.EnumResourceNamesW(module, 5, collect, 0):
            raise errors[0] if errors else C.WinError(C.get_last_error())
    finally:
        kernel.FreeLibrary(module)
    shutil.copyfile(source, target)
    update = kernel.BeginUpdateResourceW(str(target), False)
    if not update:
        raise C.WinError(C.get_last_error())
    try:
        for name, data in dialogs:
            if not kernel.UpdateResourceW(update, 5, name, 1033, data, len(data)):
                raise C.WinError(C.get_last_error())
    except Exception:
        kernel.EndUpdateResourceW(update, True)
        raise
    if not kernel.EndUpdateResourceW(update, False):
        raise C.WinError(C.get_last_error())
    print(f'Enlarged {len(dialogs)} NSIS dialogs')


if __name__ == '__main__':
    main()
