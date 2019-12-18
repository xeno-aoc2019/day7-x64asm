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

%macro output_sepline 0
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, debug_line
    mov rdx, 11
    syscall
%endmacro

%macro println_buffer 0
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, buffer
    mov rdx, 61
    syscall
%endmacro

%macro output_hex64 1
    mov r12, %1
    
    mov r11, r12 

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rdx, 1 ; length 
    mov r10, r11 ; r10 = r11
    and r10, 0xf000
    shr r10, 12
    mov rsi, hexdigits
    add rsi, r10 
    syscall
    
    mov r11, r12 

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rdx, 1 ; length 
    mov r10, r11 ; r10 = r11
    and r10, 0x0f00
    shr r10, 8
    mov rsi, hexdigits
    add rsi, r10 
    syscall
    mov r11, r12 

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rdx, 1 ; length 
    mov r10, r11 ; r10 = r11
    and r10, 0x00f0
    shr r10, 4
    mov rsi, hexdigits
    add rsi, r10 
    syscall

    mov r11, r12 

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rdx, 1 ; length 
    mov r10, r11 ; r10 = r11
    and r10, 0x000f
    mov rsi, hexdigits
    add rsi, r10 
    syscall

%endmacro

