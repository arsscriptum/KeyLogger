

; -----------------------------------------------------------
; MACRO ConsoleTitle. Changes the console title.
; -----------------------------------------------------------
macro ConsoleTitle strTitle {
     push strTitle
     call _SetTitle

}
; -----------------------------------------------------------
; MACRO Locate. Position the cursor in the screen
; -----------------------------------------------------------
macro Locate XPos,YPos{
     push YPos
     push XPos
     call _Locate

}
; -----------------------------------------------------------
; MACRO Sleep. Stop the execution for some time.
; -----------------------------------------------------------
macro Sleep miliseconds{
      invoke SleepX,miliseconds
}
; -----------------------------------------------------------
; MACRO Input . Reads from te console
; -----------------------------------------------------------
macro Input ReceipVar {
     call _Input
     mov [ReceipVar],eax

}
; -----------------------------------------------------------
; MACRO Print. Print a text to the console.
; -----------------------------------------------------------
macro Print strVariable{
     push strVariable
     call _Print
}
; -----------------------------------------------------------
; MACRO Halt. Terminates the program execution.
; -----------------------------------------------------------
macro Halt{
      invoke ExitProcess,0
}

; -----------------------------------------------------------
; MACRO OpenConsole. Open the console window.
; -----------------------------------------------------------
macro OpenConsole{
      call _OpenC
}

; -----------------------------------------------------------
; MACRO CloseConsole. Closes the console window.
; -----------------------------------------------------------
macro CloseConsole{
     call _CloseC
}
; -----------------------------------------------------------
; MACRO SetColor. Changes the Console Back adn Fore color. 0 to 15
; -----------------------------------------------------------
macro SetColor ColorValue{
     push ColorValue
     call _SetColor
}
; -----------------------------------------------------------
; MACRO CLS. Clear the console screen
; -----------------------------------------------------------
macro Cls{
     call _Clear
}
; -----------------------------------------------------------
; MACRO CLS. Clear the console screen with a color value
; -----------------------------------------------------------
macro CLSColor CLSColorValue{
     push CLSColorValue
     call _ClearColor
}


; -----------------------------------------------------------
; MACRO Inkey. Wait for a key to be pressed and return the value
; -----------------------------------------------------------
macro Inkey varReturnKeyPressed{
     call _Inkey
     mov [varReturnKeyPressed],al
}

; -----------------------------------------------------------
; MACRO WaitKey. Wait for a key to be pressed
; -----------------------------------------------------------
macro WaitKey{
     call _Inkey
}


; -----------------------------------------------------------
; MACRO StrJoin. Joins Two Strings Into One
; -----------------------------------------------------------
macro StrJoin StringA,StringB,StringResult{
     push StringA
     push StringB
     call _StrJoin
     mov [StringResult],eax
}


; -----------------------------------------------------------
; MACRO LPSTR. String Pointer.
; -----------------------------------------------------------
macro MsgBox msgboxMessage{
     invoke MessageBox,HWND_DESKTOP,msgboxMessage,MsgBoxTitle,MB_OK
}


; -----------------------------------------------------------
; MACRO STRING. Declares a new STRING (USED FOR STATIC DECLS).
; -----------------------------------------------------------
macro STRING strDeclName,strTexts
{  local ..STRINGjmpOut
   call ..STRINGjmpOut
   strDeclName db strTexts,0
   ..STRINGjmpOut:
   }

; -----------------------------------------------------------
; MACRO LPSTR. String Pointer.
; -----------------------------------------------------------
macro LPSTR strname
{    local ..LPSTRjmpOut
     call ..LPSTRjmpOut
     strname dd ?
     ..LPSTRjmpOut:
}
; -----------------------------------------------------------
; MACRO BYTE. Reserves a byte.
; -----------------------------------------------------------
macro BYTE bytename
{    local ..BYTEjmpOut
     call ..BYTEjmpOut
     bytename rb 1
     ..BYTEjmpOut:
}
; -----------------------------------------------------------
; MACRO CHAR. Reserves a byte.
; -----------------------------------------------------------
macro CHAR charname
{    local ..CHARjmpOut
     call ..CHARjmpOut
     charname rb 1
     ..CHARjmpOut:
}



; Console Modes, and color atributes
ENABLE_PROCESSED_INPUT	      = 1h
ENABLE_LINE_INPUT	      = 2h
ENABLE_ECHO_INPUT	      = 4h
ENABLE_WINDOW_INPUT	      = 8h
ENABLE_MOUSE_INPUT	      = 10h
ENABLE_PROCESSED_OUTPUT       = 1h
ENABLE_WRAP_AT_EOL_OUTPUT     = 2h
CONSOLE_TEXTMODE_BUFFER       = 1
FOREGROUND_BLUE 	      = 1h
FOREGROUND_GREEN	      = 2h
FOREGROUND_RED		      = 4h
FOREGROUND_INTENSITY	      = 8h
BACKGROUND_BLUE 	      = 10h
BACKGROUND_GREEN	      = 20h
BACKGROUND_RED		      = 40h
BACKGROUND_INTENSITY	      = 80h
struct COORD
  .x  dw      ?
  .y  dw      ?
ends

struct SMALL_RECT
  .Left      dw      ?
  .Top	     dw      ?
  .Right     dw      ?
  .Bottom    dw      ?
ends

struct CONSOLE_SCREEN_BUFFER_INFO
  .dwSize		 COORD
  .dwCursorPosition	 COORD
  .wAttributes		 dw	 ?
  .srWindow		 SMALL_RECT
  .dwMaximumWindowSize	 COORD
ends


KEY_EVENT		    = 1h
WINDOW_BUFFER_SIZE_EVENT    = 4h
MENU_EVENT		    = 8h
FOCUS_EVENT		    = 10h


RIGHT_ALT_PRESSED	    = 1h
LEFT_ALT_PRESSED	    = 2h
RIGHT_CTRL_PRESSED	    = 4h
LEFT_CTRL_PRESSED	    = 8h
SHIFT_PRESSED		    = 10h
NUMLOCK_ON		    = 20h
SCROLLLOCK_ON		    = 40h
CAPSLOCK_ON		    = 80h
ENHANCED_KEY		    = 100h

FROM_LEFT_1ST_BUTTON_PRESSED	     = 1h
RIGHTMOST_BUTTON_PRESSED	     = 2h
FROM_LEFT_2ND_BUTTON_PRESSED	     = 4h
FROM_LEFT_3RD_BUTTON_PRESSED	     = 8h
FROM_LEFT_4TH_BUTTON_PRESSED	     = 10h

MOUSE_MOVED			    = 1h
DOUBLE_CLICK			    = 2h
MOUSE_WHEELED			    = 4h

struct uCharUnion
   .UnicodeChar rd  1
   .AsciiChar	rb  1
ends

struct KEY_EVENT_RECORD
  .bKeyDown dd	?
  .wRepeatCount dd ?
  .wVirtualKeyCode dd ?
  .wVirtualScanCode dd ?
  .uChar  uCharUnion
ends

struct MOUSE_EVENT_RECORD
  .dwMousePosition COORD
  .wButtonState dw ?
  .dwControlKeyState dw ?
  .dwEventFlags dw ?
ends

struct WINDOW_BUFFER_SIZE_RECORD
  .dwSize COORD
ends

struct MENU_EVENT_RECORD
  .dwCommandId dd ?
ends

struct FOCUS_EVENT_RECORD
       .bSetFocus dd ?
ends

struct EVENTS_UNION
    .KeyEvent KEY_EVENT_RECORD
    .MouseEvent MOUSE_EVENT_RECORD
    .WindowBufferSizeEvent WINDOW_BUFFER_SIZE_RECORD
    .MenuEvent MENU_EVENT_RECORD
    .FocusEvent FOCUS_EVENT_RECORD
ends

struct INPUT_RECORD
  .EventType	dd	?
  .Event EVENTS_UNION
ends

; -----------------------------------------------------------
; FUNCTION OpenC. Opens a new windows console
; -----------------------------------------------------------
proc _OpenC
    cmp [isOpened],1 ;if is opened
    je .end  ;then not open a new one
    ;******************
    ; Initializing the variable
    ;******************
    mov [isOpened],0 ; Initializing the variable
    mov [conSetColorValue],0 ;White On Black Color (default console value)
    mov [coords.x],0
    mov [coords.y],0
    mov [conUseClearcolor],0
    ;******************

    invoke AllocConsole
    cmp eax,0
    je .end ;if the return is false, then do nothing
    invoke GetStdHandle,STD_INPUT_HANDLE
    cmp eax,INVALID_HANDLE_VALUE ;If theres an error, dont open the console
    je .end
    mov [conInputHANDLE],eax ;else, save the input handle
    invoke GetStdHandle,STD_OUTPUT_HANDLE
    cmp eax,INVALID_HANDLE_VALUE ;If theres an error, dont open the console
    je .end
    mov [conOutputHANDLE],eax ;else save the output handle
    invoke SetConsoleMode,[conInputHANDLE],(ENABLE_PROCESSED_INPUT or \
					    ENABLE_LINE_INPUT  or \
					    ENABLE_ECHO_INPUT  or \
					    ENABLE_MOUSE_INPUT	or \
					    ENABLE_WINDOW_INPUT  or \
					    ENABLE_PROCESSED_OUTPUT  or \
					    ENABLE_WRAP_AT_EOL_OUTPUT)
    mov [isOpened],1 ;to inform the status ISOPENED
    push 0
    call _SetColor
    invoke SetFocus,[dbWinHandle] ;securing main windows is focused ---
.end:
    ret
endp

; -----------------------------------------------------------
; FUNCTION _CloseC. Closes the window console.
; -----------------------------------------------------------
proc _CloseC
    cmp [isOpened],0 ;if is not opened
    je .end ;then dont close the console
    invoke FreeConsole
    mov [isOpened],0
.end:
    return
endp

; -----------------------------------------------------------
; FUNCTION PrintConsole. Print a text to the console
; -----------------------------------------------------------
proc _Print,strText
     cmp [isOpened],0 ;Take care if the console is not opened
     je .end ;if not, then dont print anything
     invoke StrCat,[strText],PRINTCRLF
     mov [PrintCRLFAddPTR],eax
     invoke lstrlen,[PrintCRLFAddPTR]
     mov [conWriteBytesLenght],eax
     invoke WriteConsole,[conOutputHANDLE],[PrintCRLFAddPTR],[conWriteBytesLenght],[conWritenBytesLenght]
.end:
     return
endp


; -----------------------------------------------------------
; FUNCTION _Input. Read one text from the console
; -----------------------------------------------------------
proc _Input
     cmp [isOpened],0 ;Take care if the console is not opened
     je .end ;if not, then dont print anything
     invoke FlushConsoleInputBuffer,[conInputHANDLE]
     invoke ReadConsole,[conInputHANDLE],conReadBuffer,1024,conReadCharAddress,NULL
     xor eax,eax
     mov esi,conReadBuffer ;starting the routine to remove the crlf chars
     mov edi,conReadBufferFinal
.loadstrloop:
     lodsb
     cmp al,13
     je .end
     mov [edi],al
     inc edi
     jmp .loadstrloop
.end:
     mov byte [edi],0
     mov eax,conReadBufferFinal
     return
endp


; -----------------------------------------------------------
; FUNCTION isConOpened. Returns 1 if is opened or 0 if is closed.
; -----------------------------------------------------------
proc isConOpened
     mov eax,[isOpened]
     return
endp


; -----------------------------------------------------------
; FUNCTION GetConColor. Returns The actual color value 0 to 15.
; -----------------------------------------------------------
proc GetConColor
     mov eax,[conSetColorValue]
     return
endp


; -----------------------------------------------------------
; FUNCTION _SetColor. Changes the Console color. 0 to 15
; -----------------------------------------------------------
proc _SetColor,parColorNumber
     cmp [isOpened],0 ;Take care if the console is not opened
     je .end ;if not, then dont print anything

     cmp [parColorNumber],0
      je .WhiteOnBlack
     cmp [parColorNumber],1
      je .RedOnBlack
     cmp [parColorNumber],2
      je .GreenOnBlack
     cmp [parColorNumber],3
      je .YellowOnBlack
     cmp [parColorNumber],4
      je .BlueOnBlack
     cmp [parColorNumber],5
      je .MagentaOnBlack
     cmp [parColorNumber],6
      je .CyanOnBlack
     cmp [parColorNumber],7
      je .BlackOnGray
     cmp [parColorNumber],8
      je .BlackOnWhite
     cmp [parColorNumber],9
      je .RedOnWhite
     cmp [parColorNumber],10
      je .GreenOnWhite
     cmp [parColorNumber],11
      je .YellowOnWhite
     cmp [parColorNumber],12
      je .BlueOnWhite
     cmp [parColorNumber],13
      je .MagentaOnWhite
     cmp [parColorNumber],14
      je .CyanOnWhite
     cmp [parColorNumber],15
      je .WhiteOnWhite
;-------------------------------------------------
     .WhiteOnBlack:
	mov [conSetColorValue],(FOREGROUND_INTENSITY or FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE)
	jmp .SetColor
     .RedOnBlack:
	mov [conSetColorValue],(FOREGROUND_INTENSITY or FOREGROUND_RED)
	jmp .SetColor
     .GreenOnBlack:
	mov [conSetColorValue],(FOREGROUND_INTENSITY or FOREGROUND_GREEN)
	jmp .SetColor
     .YellowOnBlack:
	mov [conSetColorValue],(FOREGROUND_INTENSITY or FOREGROUND_RED or FOREGROUND_GREEN)
	jmp .SetColor
     .BlueOnBlack:
	mov [conSetColorValue],(FOREGROUND_INTENSITY or FOREGROUND_BLUE)
	jmp .SetColor
     .MagentaOnBlack:
	mov [conSetColorValue],(FOREGROUND_INTENSITY or FOREGROUND_RED or FOREGROUND_BLUE)
	jmp .SetColor
     .CyanOnBlack:
	mov [conSetColorValue],(FOREGROUND_INTENSITY or FOREGROUND_GREEN or FOREGROUND_BLUE)
	jmp .SetColor
     .BlackOnGray:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or BACKGROUND_INTENSITY)
	jmp .SetColor
     .BlackOnWhite:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or FOREGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE)
	jmp .SetColor
     .RedOnWhite:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or FOREGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE or FOREGROUND_RED)
	jmp .SetColor
     .GreenOnWhite:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or FOREGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE or FOREGROUND_GREEN)
	jmp .SetColor
     .YellowOnWhite:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or FOREGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE or FOREGROUND_RED or FOREGROUND_GREEN)
	jmp .SetColor
     .BlueOnWhite:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or FOREGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE or FOREGROUND_BLUE)
	jmp .SetColor
     .MagentaOnWhite:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or FOREGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE or FOREGROUND_RED or FOREGROUND_BLUE)
	jmp .SetColor
     .CyanOnWhite:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or FOREGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_BLUE)
	jmp .SetColor
     .WhiteOnWhite:
	mov [conSetColorValue],(BACKGROUND_INTENSITY or FOREGROUND_INTENSITY or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE or FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE)
	jmp .SetColor
;-------------------------------------------------

.SetColor:
     invoke SetConsoleTextAttribute,[conOutputHANDLE],[conSetColorValue]
     mov eax,[parColorNumber]
     mov [conSetColorValue],eax
.end:
     return
endp


; -----------------------------------------------------------
; FUNCTION _Locate. Changes the cursor position.
; -----------------------------------------------------------
proc _Locate,curX,curY
     cmp [isOpened],0 ;Take care if the console is not opened
     je .end ;if not, then dont print anything
     mov eax,[curX]
     mov dword [coords.x],eax
     mov eax,[curY]
     mov dword [coords.y],eax
     invoke SetConsoleCursorPosition,[conOutputHANDLE],[coords]
.end:
     return
endp


; -----------------------------------------------------------
; FUNCTION _Clear. Clears the console.
; -----------------------------------------------------------
proc _Clear
     cmp [isOpened],0 ;Take care if the console is not opened
     je .end ;if not, then dont print anything
     mov [coords.x],0
     mov [coords.y],0
     cmp [conUseClearcolor],1
     je .withcolor
     push 0
     call _SetColor
     jmp .next
.withcolor:
     push [conClearColor]
     call _SetColor
.next:
     invoke GetConsoleScreenBufferInfo,[conOutputHANDLE],CSBI
     mov eax,dword [CSBI.dwSize.x]
     mul [CSBI.dwSize.y]
     mov dword [dwConSize],edx
     invoke FillConsoleOutputCharacter,[conOutputHANDLE],20h,dword [dwConSize],[coords],conCharsWritten
     invoke GetConsoleScreenBufferInfo,[conOutputHANDLE],CSBI
     invoke FillConsoleOutputAttribute,[conOutputHANDLE],dword [CSBI.wAttributes],dword [dwConSize],[coords],conCharsWritten
     invoke SetConsoleCursorPosition,[conOutputHANDLE],[coords]
.end:
     return
endp


; -----------------------------------------------------------
; FUNCTION _ClearColor. Clears the console and set a color
; -----------------------------------------------------------
proc _ClearColor,paramColorNum
     cmp [isOpened],0 ;Take care if the console is not opened
     je .end ;if not, then dont print anything
     mov eax,[paramColorNum]
     mov [conClearColor],eax
     mov [conUseClearcolor],1
     call _Clear
     mov [conUseClearcolor],0
.end:
     return
endp

; -----------------------------------------------------------
; FUNCTION _SetTitle. Changes the console title.
; -----------------------------------------------------------
proc _SetTitle,strTitleParam
     cmp [isOpened],0 ;Take care if the console is not opened
     je .end ;if not, then dont print anything
     invoke SetConsoleTitle,[strTitleParam]
.end:
     return
endp

; -----------------------------------------------------------
; FUNCTION StrJoin. Join Two Strings into one.
; -----------------------------------------------------------
proc _StrJoin,strParamA,strParamB
     cmp [isOpened],0 ;Take care if the console is not opened
     je .end ;if not, then dont print anything
     invoke StrCat,[strParamA],[strParamB]
.end:
     return
endp

; -----------------------------------------------------------
; FUNCTION _Inkey. Wait for a key press and return the key in eax.
; -----------------------------------------------------------
proc _Inkey
     invoke FlushConsoleInputBuffer,[conInputHANDLE]
    .loopInKey:
     invoke ReadConsoleInput,[conInputHANDLE],InputRECORD,[InputRECORDSize],InputEventsReceived
     cmp [InputRECORD.EventType],KEY_EVENT
    jne .loopInKey
     mov eax,[InputRECORD.Event.KeyEvent.wVirtualKeyCode]
     invoke FlushConsoleInputBuffer,[conInputHANDLE]
     invoke ReadConsoleInput,[conInputHANDLE],InputRECORD,[InputRECORDSize],InputEventsReceived
    return
endp

; -----------------------------------------------------------
; FUNCTION GetENV. Gets an enviroment variable value
; -----------------------------------------------------------
proc GetENV,strEnvName
    invoke GetEnvironmentVariable,[strEnvName+4],varStrBuffer,65535
    mov eax,varStrBuffer
    return
endp


; -----------------------------------------------------------
; FUNCTION SetENV. Sets a new enviroment variable
; -----------------------------------------------------------
proc SetENV,strEnvName,strEnvValue
    invoke SetEnvironmentVariable,[strEnvName],[strEnvValue]
    return
endp



; -----------------------------------------------------------
; DATA SECTION
; -----------------------------------------------------------
section '.data' data readable writable
	PRINTCRLF		   db	    13,10,0
	CSBI			   CONSOLE_SCREEN_BUFFER_INFO
	coords			   COORD
	InputRECORD		   INPUT_RECORD
	InputRECORDSize 	   dd	    $ - InputRECORD
	InputEventsReceived	   dd	    0
	dwConSize		   dw	    0
	conCharsWritten 	   dw	    0
	PrintCRLFAddPTR 	   dd	    0
	dbWinHandle		   dd	    ?
	isOpened		   dd	    ?
	conInputHANDLE		   dd	    ?
	conOutputHANDLE 	   dd	    ?
	conWriteBytesLenght	   dd	    ?
	conWritenBytesLenght	   dd	    ?
	conReadCharAddress	   dd	    ?
	conClearColor		   dd	    ?
	conUseClearcolor	   dd	    ?
	conSetColorValue	   dd	    ?
	varParamPointers	   dd	    ?
	conReadBuffer		   rb	    1024
	conReadBufferFinal	   rb	    1024
	varStrBuffer		   rb	    65535