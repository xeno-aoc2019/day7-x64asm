%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
; %include "writenum.inc"

; handle_error error_code errno

default rel
global _fprintd
section .text

; RDI, RSI, RDX, RCX, R8, R9

; _memalloc, rax=size => rax=ptr
; rax=fd, rdi=num

;  [fd] digits
_fprintd: ; FD(rdi) num(rax)
    xor r8, r8
    xor rdx, rdx
    mov rsi, 10
.start:
    xor rdx, rdx
    mov rcx, rax
    jrcxz .done_pushing
    idiv rsi
    push rdx
    inc r8
    jmp .start
.done_pushing:
    xor r9,r9
.digit:
    cmp r8,r9
    je .end
    mov rax, SYS_WRITE
;    mov rdi, 1 ;  <- this is an argument, hopefully not destroyed by now
    mov rdx, 1 ; length  
    mov rsi, digits
    pop r10
    add rsi, r10 
    syscall
    inc r9
    jmp .digit
.end:
    ret

section .data
digits          db    "0123456789"
_0              db    0x30
_9              db    0x39
newline:        db    10
debug1:         db    "printd:1",10
.len            equ   $ - debug1
debug2:         db    "printd:2",10
.len            equ   $ - debug2

