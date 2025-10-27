;-------------------------------------------------
; ATM PROCESS SIMULATION IN ASSEMBLY LANGUAGE (8086)
; Compatible with EMU8086, MASM, TASM
; Includes PIN verification + success messages
;-------------------------------------------------

.MODEL SMALL
.STACK 100H

.DATA
welcome_msg DB 13,10, '*** WELCOME TO ATM SYSTEM ***',13,10, '$'
pin_prompt  DB 13,10, 'Enter 4-digit PIN: $'
pin_error   DB 13,10, 'Invalid PIN! Try again.$'
menu_msg    DB 13,10, '*** ATM MAIN MENU ***',13,10
            DB '1. Check Balance',13,10
            DB '2. Deposit Money',13,10
            DB '3. Withdraw Money',13,10
            DB '4. Exit',13,10
            DB 'Enter your choice: $'

balance_msg DB 13,10, 'Your current balance is: $'
deposit_msg DB 13,10, 'Enter amount to deposit: $'
withdraw_msg DB 13,10, 'Enter amount to withdraw: $'
thanks_msg  DB 13,10, 'Thank you for using ATM. Goodbye!$'
new_line    DB 13,10, '$'
insuf_msg   DB 13,10, 'Insufficient balance!$'
dep_success DB 13,10, 'Deposit Successful!$'
with_success DB 13,10, 'Withdrawal Successful!$'

correct_pin DB '1234', '$'   ; The correct PIN
user_pin    DB 5 DUP(?)      ; Buffer for user input (4 digits + null)

balance_val DW 5000          ; Initial balance
choice      DB ?
amount      DW ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

;--------------------------------
; PIN VERIFICATION
;--------------------------------
PIN_ENTRY:
    LEA DX, welcome_msg
    MOV AH, 09H
    INT 21H

    LEA DX, pin_prompt
    MOV AH, 09H
    INT 21H

    ; Read 4 digits
    MOV SI, OFFSET user_pin
    MOV CX, 4
READ_PIN_LOOP:
    MOV AH, 01H
    INT 21H
    MOV [SI], AL
    INC SI
    LOOP READ_PIN_LOOP
    MOV BYTE PTR [SI], '$'

    ; Compare entered PIN with correct PIN
    MOV SI, OFFSET user_pin
    MOV DI, OFFSET correct_pin
    MOV CX, 4
COMPARE_PIN:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE WRONG_PIN
    INC SI
    INC DI
    LOOP COMPARE_PIN
    JMP START_MENU

WRONG_PIN:
    CALL PRINT_NEWLINE
    LEA DX, pin_error
    MOV AH, 09H
    INT 21H
    CALL PRINT_NEWLINE
    JMP PIN_ENTRY

;--------------------------------
; MAIN ATM MENU
;--------------------------------
START_MENU:
START:
    LEA DX, menu_msg
    MOV AH, 09H
    INT 21H

    ; Get user choice
    MOV AH, 01H
    INT 21H
    SUB AL, 30H
    MOV choice, AL

    CMP choice, 1
    JE CHECK_BALANCE

    CMP choice, 2
    JE DEPOSIT

    CMP choice, 3
    JE WITHDRAW

    CMP choice, 4
    JE EXIT_PROGRAM

    JMP START

;--------------------------------
CHECK_BALANCE:
    LEA DX, balance_msg
    MOV AH, 09H
    INT 21H

    MOV AX, balance_val
    CALL PRINT_NUM

    CALL PRINT_NEWLINE
    JMP START

;--------------------------------
DEPOSIT:
    LEA DX, deposit_msg
    MOV AH, 09H
    INT 21H

    CALL READ_NUM
    ADD balance_val, AX

    LEA DX, dep_success
    MOV AH, 09H
    INT 21H

    CALL PRINT_NEWLINE
    LEA DX, balance_msg
    MOV AH, 09H
    INT 21H

    MOV AX, balance_val
    CALL PRINT_NUM

    CALL PRINT_NEWLINE
    JMP START

;--------------------------------
WITHDRAW:
    LEA DX, withdraw_msg
    MOV AH, 09H
    INT 21H

    CALL READ_NUM
    CMP AX, balance_val
    JA NOT_ENOUGH
    SUB balance_val, AX

    LEA DX, with_success
    MOV AH, 09H
    INT 21H

    CALL PRINT_NEWLINE
    LEA DX, balance_msg
    MOV AH, 09H
    INT 21H

    MOV AX, balance_val
    CALL PRINT_NUM
    JMP AFTER_WITHDRAW

NOT_ENOUGH:
    LEA DX, insuf_msg
    MOV AH, 09H
    INT 21H

AFTER_WITHDRAW:
    CALL PRINT_NEWLINE
    JMP START

;--------------------------------
EXIT_PROGRAM:
    LEA DX, thanks_msg
    MOV AH, 09H
    INT 21H
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;--------------------------------
; SUBROUTINES
;--------------------------------

READ_NUM PROC
    XOR CX, CX
    MOV BX, 10
READ_LOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 13
    JE READ_DONE
    SUB AL, 30H
    MOV AH, 0
    MOV DX, CX
    MUL BX
    ADD AX, DX
    MOV CX, AX
    JMP READ_LOOP
READ_DONE:
    MOV AX, CX
    RET
READ_NUM ENDP

PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10
PN_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE PN_LOOP

PN_PRINT:
    POP DX
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    LOOP PN_PRINT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

PRINT_NEWLINE PROC
    LEA DX, new_line
    MOV AH, 09H
    INT 21H
    RET
PRINT_NEWLINE ENDP

END MAIN
