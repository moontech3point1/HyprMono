#!/usr/bin/env python3
#
# Listens to every keyboard device directly through evdev and waits for the user to
# hold down one of the allowed modifier keys/combos. Needs to be run as root (or as a
# user in the "input" group) since /dev/input/event* isn't readable otherwise.
#
# This has to be a real file run with a real terminal attached, NOT piped in through a
# heredoc/stdin, because we still need stdin free afterwards for the y/n confirmation
# prompts. Learned that one the hard way.
#
# Usage: remap-key.py <path to write the result to>
# Writes one line to that file when done:
#   a hyprland-ready mod string like "CTRL + ALT", or
#   "UNSUPPORTED:<display name>" if the user picked something Hyprland can't actually
#   bind a chord off of (Tab, Alt+Tab, the Copilot key)

import sys
import os
import select

try:
    import evdev
    from evdev import ecodes
except ImportError:
    print("python-evdev isn't installed, can't do the interactive remap. Run: sudo pacman -S python-evdev")
    sys.exit(1)

if len(sys.argv) < 2:
    print("internal error: remap-key.py needs an output path")
    sys.exit(1)

result_path = sys.argv[1]

# groups of keycodes that count as "the same key" for our purposes (left/right variants)
KEY_GROUPS = {
    "TAB": {ecodes.KEY_TAB},
    "SHIFT": {ecodes.KEY_LEFTSHIFT, ecodes.KEY_RIGHTSHIFT},
    "CTRL": {ecodes.KEY_LEFTCTRL, ecodes.KEY_RIGHTCTRL},
    "META": {ecodes.KEY_LEFTMETA, ecodes.KEY_RIGHTMETA},
    "ALT": {ecodes.KEY_LEFTALT, ecodes.KEY_RIGHTALT},
}

# the copilot key is pretty new (kernel added KEY_ASSISTANT for it), older kernels
# might not even have this constant, so we have to check before using it
if hasattr(ecodes, "KEY_ASSISTANT"):
    KEY_GROUPS["COPILOT"] = {ecodes.KEY_ASSISTANT}
else:
    KEY_GROUPS["COPILOT"] = set()

# every keycode that belongs to one of the groups above, used to spot when the user
# accidentally has a letter/number/symbol key mixed in with the modifiers
ALLOWED_CODES = set()
for group in KEY_GROUPS.values():
    ALLOWED_CODES |= group

# combo (as a frozenset of group names) -> (name shown to the user, hyprland mod string or None)
# None means it's a valid pick but hyprland genuinely can't bind a hold-modifier off it
ALLOWED_COMBOS = {
    frozenset({"TAB"}): ("Tab", None),
    frozenset({"SHIFT"}): ("Shift", "SHIFT"),
    frozenset({"CTRL"}): ("Ctrl", "CTRL"),
    frozenset({"CTRL", "SHIFT"}): ("Ctrl + Shift", "CTRL + SHIFT"),
    frozenset({"META"}): ("Windows / Meta", "SUPER"),
    frozenset({"ALT"}): ("Alt", "ALT"),
    frozenset({"SHIFT", "ALT"}): ("Shift + Alt", "ALT + SHIFT"),
    frozenset({"CTRL", "ALT"}): ("Ctrl + Alt", "CTRL + ALT"),
    frozenset({"ALT", "TAB"}): ("Alt + Tab", None),
    frozenset({"COPILOT"}): ("Copilot key", None),
}


def code_to_group(code):
    for name, codes in KEY_GROUPS.items():
        if code in codes:
            return name
    return None


def find_keyboards():
    devices = []
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
        except OSError:
            continue
        caps = dev.capabilities().get(ecodes.EV_KEY, [])
        # if it can send a plain letter key it's probably an actual keyboard and not
        # something weird like a power button or a webcam that also shows up here
        if ecodes.KEY_A in caps:
            devices.append(dev)
    return devices


def drain_pending(devices):
    # The y/N confirmation is answered on the same keyboard that is being monitored, so those keypresses
    # remain buffered in the devices. Discard them before listening again, otherwise they are read as a
    # new (invalid) combo and trigger a spurious error message.
    for dev in devices:
        while select.select([dev], [], [], 0)[0]:
            list(dev.read())


def wait_for_combo(devices):
    """Blocks until the user presses+releases a valid modifier combo (or something
    invalid, in which case it just complains and keeps listening)."""
    drain_pending(devices)
    held = set()
    peak = set()
    saw_disallowed_key = False

    while True:
        r, _, _ = select.select(devices, [], [])
        for dev in r:
            for event in dev.read():
                if event.type != ecodes.EV_KEY:
                    continue
                if event.value == 1:  # key down
                    held.add(event.code)
                    peak.add(event.code)
                    if event.code not in ALLOWED_CODES:
                        saw_disallowed_key = True
                elif event.value == 0:  # key up
                    held.discard(event.code)
                    if not held:
                        # everything's released, time to see what they actually pressed
                        if saw_disallowed_key or not peak:
                            print("that's not a letter/number/symbol-free combo, try again "
                                  "(Tab, Shift, Ctrl, Ctrl+Shift, Windows, Alt, Shift+Alt, "
                                  "Ctrl+Alt, Alt+Tab, or Copilot only)")
                            held = set()
                            peak = set()
                            saw_disallowed_key = False
                            continue

                        groups = frozenset(g for g in (code_to_group(c) for c in peak) if g)
                        if len(groups) != len(peak) or groups not in ALLOWED_COMBOS:
                            print("that combo isn't one of the allowed ones, try again")
                            held = set()
                            peak = set()
                            saw_disallowed_key = False
                            continue

                        return ALLOWED_COMBOS[groups]


def main():
    devices = find_keyboards()
    if not devices:
        print("couldn't find any keyboard devices under /dev/input, falling back to SUPER")
        with open(result_path, "w") as f:
            f.write("SUPER")
        return

    print("")
    print("hold down the key (or combo) you want as your main modifier")
    print("allowed: Tab, Shift, Ctrl, Ctrl+Shift, Windows, Alt, Shift+Alt, Ctrl+Alt, Alt+Tab, Copilot")
    print("")

    while True:
        display_name, mod_string = wait_for_combo(devices)
        answer = input(f"you held down: {display_name} - use this? [y/N] ").strip().lower()
        if answer in ("y", "yes"):
            with open(result_path, "w") as f:
                if mod_string is None:
                    f.write(f"UNSUPPORTED:{display_name}")
                else:
                    f.write(mod_string)
            print(f"got it, using {display_name}")
            return
        print("ok, press the key(s) you want again")


if __name__ == "__main__":
    main()
