%include "syscalls.mac"

global start
section .text
start:
   
   ; open(filename, RO, -)
    mov rax,  SYS_OPEN
    mov rdi,  msg ; filename
    mov rsi,  O_RDONLY ;  flags=ro
    mov rdx, 0 ; mode, not used
    syscall

   ; write(1, msg, len)
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, msg
    mov rdx, msg.len
    syscall

    ; exit(0)
    mov rax, SYS_EXIT ; exit
    mov rdi,  EXIT_SUCCESS
    syscall

section .data
msg:        db    "Hello, world!", 10
.len:         equ     $ - msg
filename: db    "input.txt"