%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"

default rel
global start
section .text
start:
   
    mov rax, SYS_OPEN
    mov rdi, filename 
    mov rsi, O_RDONLY ; flags=ro
    mov rdx, 0        ; mode, not used
    syscall
    mov [input_fd], rax

    io_open_outfile [output_fd], outfile

    mov [output_fd], rax

    ; write to stdout
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, msg
    mov rdx, msg.len
    syscall

    output_digit FD_STDOUT
    output_newline
    output_digit [output_fd]
    output_newline

    ; write to output file
    mov rax, SYS_WRITE
    mov rdi, [output_fd]
    mov rsi, msg
    mov rdx, msg.len
    syscall

    ; close it 
    io_close [output_fd]

    ;; experiment

    mov r11, 0xa4bc ; should be output as 0xa4bc

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rdx, 1 ; length 
    mov r10, r11 ; r10 = r11
    and r10, 0xf000
    shr r10, 24
    mov rsi, hexdigits
    add rsi, r10 ; adding the hex digit...
    syscall

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rdx, 1 ; length 
    mov r10, r11 ; r10 = r11
    and r10, 0x0f00
    shr r10, 16
    mov rsi, hexdigits
    add rsi, r10 ; adding the hex digit...
    syscall

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rdx, 1 ; length 
    mov r10, r11 ; r10 = r11
    and r10, 0x00f0
    shr r10, 8
    mov rsi, hexdigits
    add rsi, r10 ; adding the hex digit...
    syscall

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rdx, 1 ; length 
    mov r10, r11 ; r10 = r11
    and r10, 0x000f
    mov rsi, hexdigits
    add rsi, r10 ; adding the hex digit...
    syscall
    output_newline


    ; output_digit r11
    ; output_newline
    


    ; exit(0)
    sys_exit EXIT_SUCCESS

section .data

msg:        db    "Hello, world!", 10
.len:       equ   $ - msg
filename:   db    "input.txt",0
outfile:    db    "output.txt",0
input_fd:   dq     0x0
output_fd:  dq     0x0
digits:     db     "123456789_123456789_123456789"
newline:    db     10
hexdigits:  db     "0123456789abcdef***" 
