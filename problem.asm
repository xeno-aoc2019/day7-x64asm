%include "printd.inc"

%define SYS_EXIT         0x2000001
%define SYS_READ         0x2000003
%define SYS_WRITE        0x2000004
%define SYS_OPEN         0x2000005
%define SYS_CLOSE        0x2000006
%define SYS_MMAP         0x20000c5

%define EXIT_SUCCESS     0
%define EXIT_FAILURE     1

%define FD_STDIN         0
%define FD_STDOUT        1
%define FD_STDERR        2

%macro debug_num 2 
    push r10
    push r11
    mov r10, %1
    mov r11, %2
    ; printd r10
    ; printd r10
    fprints 1, space, 1
    printd r11
    printd r10
    println
    pop r11
    pop r10
%endmacro

%macro sys_exit 1
    mov rax, SYS_EXIT ; exit
    mov rdi, %1
    syscall
%endmacro

; fprints [fd] buffer length
%macro fprints 3
    push rax
    push rdi
    push rsi
    push rdx
    push r10
    push r11
    mov rax, SYS_WRITE
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
    pop r11
    pop r10
    pop rdx
    pop rsi
    pop rdi
    pop rax
%endmacro

%macro prints 2  
    fprints FD_STDOUT, %1, %2
%endmacro

%macro println 0
    prints newline, 1
%endmacro

default rel
global start
section .text

start:
    debug_num 10, 100
    println
    sys_exit 0

section .data

newline         db    10
space           db    " "
 