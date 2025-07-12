keylogger
=========

FASM Win32 application source code for a keylogger. POC. Don't use it and think you won't be caught

# 🔎 Summary of Functionality

### Entry Point

* Creates a thread that starts `KeyLogger`.
* Waits for it to finish.
* Enters a perpetual loop calling `LoopFunc`.

---

## `KeyLogger` procedure

* Obtains the module handle.
* Installs a low-level keyboard hook (`SetWindowsHookExA` with `WH_KEYBOARD_LL`) pointing to:

  ```
  LowLevelKeyboardProc
  ```
* Enters a message loop via `GetMessageA`.

---

## `LowLevelKeyboardProc`

* Only processes messages where:

  ```
  nCode = HC_ACTION
  wParam = WM_SYSKEYDOWN or WM_KEYDOWN
  ```

* Grabs details from the `KBDLLHOOKSTRUCT` structure:

  * virtual key code
  * scan code
  * flags

* Retrieves the current foreground window text. If it changes:

  * Logs the window name plus timestamp into the log file.

* For each key:

  * Checks if modifier keys (Ctrl, Alt, Win) are pressed.

    * Logs combinations like:

      ```
      [CtrlL + A]
      ```
  * Logs named special keys (e.g. `[Backspace]`, `[Enter]` etc.)
  * Otherwise:

    * Calls `ToUnicodeEx` to translate virtual keys to Unicode characters and logs the character.

* Calls `CallNextHookEx` to pass the event to other hooks.

---

## File Logging

Uses `WriteToFile`:

* Opens `c:\Tmp\log_file.txt` with `FILE_APPEND_DATA`.
* Writes the Unicode string passed to it.
* Closes the file.

---

## Process Info

`CheckInstances`:

* Checks for single-instance logic (currently commented out).
* Logs computer name.

---

## Helper procs

* `ReadTheInput`:

  * Reads a file from STDIN into a dynamic memory buffer.
* `MyPrintNumber`:

  * Prints floating-point value using `printf`.
* `MyPrintString`:

  * Prints C-string “test” via `printf` and exits.

# Misc

- Uses proper Unicode handling for key names.
- Handles modifier keys like Ctrl, Win, etc.
- Clears virtual memory properly after keyboard state reading.
- Logs window titles to correlate with keystrokes.

---

# ⭐️ How it Works

This is a relatively full-featured keylogger:

* It monitors all keyboard activity globally via WH\_KEYBOARD\_LL.
* Tracks foreground window changes and timestamps.
* Dumps keys into a text file in Unicode format.
* Even handles combinations (e.g. `[CtrlL + X]`).
* Operates persistently via a message loop.

---

# 🎯 Suggestions for Improvement

- Re-enable mutex check:

```asm
invoke CreateMutexA, NULL, FALSE, onlyOneCopy
invoke GetLastError
cmp eax, ERROR_ALREADY_EXISTS
je more_than_one_copy
```

- Replace `exit` with `ret` or orderly thread termination.

- Add proper error checking:

```asm
test eax, eax
je error_exit
```

- Use relative paths or configurable logging.

- Handle `ToUnicodeEx` results:

```asm
cmp eax, 0
jle skip_write
```
