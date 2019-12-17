%include "sysconst.inc"
%include "syscall.inc"


%macro push_last_dec_digit_rax 0
    xor rdx, rdx
    mov rdi, 10
    div rdi
    push rdx
%endmacro

; write_digit_from_stack [fd] -- write the digit on top of the stack
%macro write_digit_from_stack 1
    mov rax, SYS_WRITE
    mov rdi, %1
    mov rdx, 1 ; length 
    mov rsi, hexdigits
    pop r10
    add rsi, r10 
    syscall
%endmacro 

; print_digits5 [fd] digits
%macro fprintd 2
    mov rax, %2

    push_last_dec_digit_rax
    push_last_dec_digit_rax
    push_last_dec_digit_rax
    push_last_dec_digit_rax
    push_last_dec_digit_rax
    push_last_dec_digit_rax
    push_last_dec_digit_rax
    push_last_dec_digit_rax

    write_digit_from_stack %1
    write_digit_from_stack %1
    write_digit_from_stack %1
    write_digit_from_stack %1
    write_digit_from_stack %1
    write_digit_from_stack %1
    write_digit_from_stack %1
    write_digit_from_stack %1
%endmacro

%macro printd 1
   fprintd FD_STDOUT, %1
%endmacro
