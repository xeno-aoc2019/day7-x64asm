

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

%macro output_failure 0
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, failure
    mov rdx, 8
    syscall
%endmacro

%macro output_success 0
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, success
    mov rdx, 8
    syscall
%endmacro

%macro println_buffer 0
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, buffer
    mov rdx, 61
    syscall
%endmacro

; println regname reg
%macro println_reg 2
    push %2
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, %1
    mov rdx, 5
    syscall
    printd %2
    output_newline
    pop %2
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

%macro unused_old_mmap 0
   ; allocate some memory
    mov rax, SYS_MMAP
    xor rdi, rdi ; memory address, 0 = let the system find some
    mov rsi, 1000 ; size
    mov rdx, 7 ; RWX 
    mov r10, MAP_ANON_PRIV
    mov r8,  -1 ; fd
    xor r9,  r9 ; offset
    syscall

    mov r13, rdi 
    mov r12, rax
    jc fail_1
    output_success
    jmp cont_1
fail_1:
    printd rcx
    output_newline
    output_failure
cont_1:

    printd r12 ; ? 
    output_newline
    printd r13 ;
    output_newline 

    println_buffer

    output_sepline
%endmacro

%macro trace 1
    prints trace_lab, 7
    printd %1
    println
%endmacro