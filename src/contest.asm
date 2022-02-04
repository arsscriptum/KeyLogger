 
;********************************************************************
; CONSOLE UTILS
; GNU GENERAL PUBLIC LICENCED, BY ZONA SERVICES.
; HTTP://WWW.ZONAUY.COM - FLORIDA URUGUAY
;********************************************************************

; -----------------------------------------------------------
; PARAMS
; -----------------------------------------------------------
format PE GUI 4.0
entry MAIN
include 'conutils.inc'


; -----------------------------------------------------------
; VARIABLES
; -----------------------------------------------------------
section '.data' data readable writable
   LPSTR strTestInput
   STRING IntroMessage,'Write your name: '
   STRING HelloMessage,'Hello '
   STRING MsgBoxTitle,'Message:'
   STRING ConsoleOpenMessage,'Now Console Opened...'
   STRING ConsoleClosedMessage,'Now Console Closed!'
   STRING ConsoleOpenedAgainMessage,'Now Console Opened Again...'
   STRING ConsoleClosedExitMessage,<'Now Console Closed Again!',13,10,"And Now I'll Exit Smile">

; -----------------------------------------------------------
; CODE START
; -----------------------------------------------------------
section '.code' code readable executable

; -----------------------------------------------------------
; MAIN PROC
; -----------------------------------------------------------
proc MAIN
        OpenConsole ;Open the console window
        Print ConsoleOpenMessage ;Print in the console
        Input strTestInput ;Wait for press enter
        CloseConsole ;Close the console
        MsgBox ConsoleClosedMessage ;Show the message box
        OpenConsole  ;Reopen a new console
        SetColor 3  ;Change the print color
        Print ConsoleOpenedAgainMessage ;Print to the console
        Input strTestInput ;Wait for enter..
        CloseConsole ;Close The Console
        MsgBox ConsoleClosedExitMessage ;Show exit message
        Halt
endp