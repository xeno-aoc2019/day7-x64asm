%include "syscalls.mac"
default rel
global start
section .text
start:
   
    mov rax, SYS_OPEN
    mov rdi, filename 
    mov rsi, O_RDONLY ;  flags=ro
    mov rdx, 0 ; mode, not used
    syscall
    mov  qword [input_fd], rax

    mov rax, SYS_OPEN
    mov rdi, outfile
    mov rsi, O_CREATE_WRITE ;  flags=ro
    mov rdx, 0666o; mode
    syscall
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
    mov rax, SYS_CLOSE
    mov rdi, [output_fd]
    syscall

    ; exit(0)
    mov rax, SYS_EXIT ; exit
    mov rdi, EXIT_SUCCESS
    syscall

section .data

msg:        db    "Hello, world!", 10
.len:       equ   $ - msg
filename:   db    "input.txt"
outfile:    db    "output.txt"
input_fd:   dq     0x0
output_fd:  dq     0x2
digits:     db     "0123456789_123456789_123456789"
newline:    db     10
