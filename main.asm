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
    jc fail_0
    output_success
    jmp cont_0
fail_0:
    output_failure
cont_0:

    ; allocate some memory
    mov rax, SYS_MMAP
    xor rdi, rdi ; memory address, 0 = let the system find some
    mov rsi, 1000 ; size
    mov rdx, 7 ; RWX 
    mov rcx, MAP_ANON_PRIV
    mov r8,  -1 ; fd
    mov r9,  0 ; offset
    syscall

    mov r13, rdi 
    mov r12, rax
    jc fail_1
    output_success
    jmp cont_1
fail_1:
   output_failure
cont_1:

    printd r12 ; ? 
    output_newline
    printd r13 ;
    output_newline 

    println_buffer

    output_sepline
    mov rax, SYS_READ
    mov rdi, [input_fd]
;    mov rsi, r12
    mov rsi, buffer
    mov rdx, 20
    syscall
    cmp rax, 0
    mov r12, rax
    jl fail_2
    printd 20001
    output_newline
    jmp cont_2
fail_2:
    printd 20002
    output_newline
cont_2:
    printd r12
    output_newline

    println_buffer

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

msg:          db    "Hello, world!", 10
.len:         equ   $ - msg
filename:     db    "input.txt",0
outfile:      db    "output.txt",0
input_fd:     dq    0x0
output_fd:    dq    0x0
digits:       db    "123456789_123456789_123456789"
newline:      db    10
comma         db    0x2c
space         db    0x20
zero_chr      db    0x30
hexdigits:    db    "0123456789abcdef***" 
debug_line:   db    "----------",10
failure:      db    "failure",10
success:      db    "success",10
buffer:       db    "____________________________________________________________",10
input_buf_p:  dq    0x0 ; ptr to memory buffer for parsing
input_p       dq    0x0 ; ptr to current pos in parsing
input_buf_size: dq    5 ; size of input
program_ptr:  dq    0x0 ; ptr to parsed program
 