%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "writenum.inc"

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

    ; allocate some memory
    mov rax, SYS_MMAP
    xor rdi, rdi
    mov rsi, 1000 ; size
    mov rdx, PROT_RW
    mov rcx, MAP_PRIVATE
    mov r8,  0
    mov r9,  0
    syscall

    mov r12, rax
    cmp rax, 0
    jl failure_1
    printd 10001
    output_newline
    jmp cont_1
failure_1:
    printd 10002
    output_newline
cont_1:

    printd r12 ; ? 
    output_newline
    printd r12 ;
    output_newline 

    output_sepline
    mov rax, SYS_READ
    mov rdi, [input_fd]
    mov rsi, r12
    mov rdx, 20
    syscall
    printd rax
    output_newline

    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, r12
    mov rdx, 20
    syscall

    output_newline

    io_open_outfile [output_fd], outfile

    mov [output_fd], rax

    ; write to stdout
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT
    mov rsi, msg
    mov rdx, msg.len
    syscall

    ; write to output file
    mov rax, SYS_WRITE
    mov rdi, [output_fd]
    mov rsi, msg
    mov rdx, msg.len
    syscall

    ; close it 
    io_close [output_fd]

    ; output_digit r11
    ; output_newline
    
    output_sepline
    printd 10012345
    output_newline
    mov rax, 1231231
    printd rax
    output_newline

    ; exit(0)
    sys_exit EXIT_SUCCESS

section .data

msg:        db    "Hello, world!", 10
.len:       equ   $ - msg
filename:   db    "input.txt",0
outfile:    db    "output.txt",0
input_fd:   dq    0x0
output_fd:  dq    0x0
digits:     db    "123456789_123456789_123456789"
newline:    db    10
hexdigits:  db    "0123456789abcdef***" 
debug_line: db    "----------",10
failure:    db    "failure",10
success:    db    "success",10