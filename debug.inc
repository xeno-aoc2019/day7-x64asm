%macro output_digit 1
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, digits
    mov rdx, %1
    syscall
%endmacro

%macro output_newline 0
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, newline
    mov rdx, 1
    syscall
%endmacro