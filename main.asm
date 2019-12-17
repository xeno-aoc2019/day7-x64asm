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
;    mov rax, SYS_OPEN
;    mov rdi, outfile
;    mov rsi, O_CREATE_WRITE ;  flags=ro
;    mov rdx, 0666o; mode
;    syscall
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
    output_digit rax
    output_newline
    output_digit [output_fd]
    output_newline
    output_digit rdi
    output_newline

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
filename:   db    "input.txt",0
outfile:    db    "output.txt",0
input_fd:   dq     0x0
output_fd:  dq     0x0
digits:     db     "123456789_123456789_123456789"
newline:    db     10
