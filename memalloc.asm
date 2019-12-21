%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "writenum.inc"

; handle_error error_code errno

default rel
global _memalloc
section .text
;; open input file

; RDI, RSI, RDX, RCX, R8, R9

; _memalloc, rax=size => rax=ptr
_memalloc: ; size -> ptr
    mov rsi, rax ; size
    mov rax, SYS_MMAP
    xor rdi, rdi ; memory address, 0 = let the system find some
    mov rdx, 7 ; RWX 
    mov r10, MAP_ANON_PRIV
    mov r8,  -1 ; fd
    xor r9,  r9 ; offset
    syscall
    jc fail
    ret

fail:
    mov r13, rax
    prints memfailed, memfailed.len
    println
    prints errno, errno.len
    println
    sys_exit EXIT_FAILURE
    ret


section .data
input_fd        dq    0x10
output_buf      dq    0x10
msg:            db    "Hello, test!", 10
.len:           equ   $ - msg
newline:        db    0x0a
comma:          db    0x2c
_0              db    0x30
_9              db    0x39
memfailed       db   "Memory allocation failed",10
.len            equ   $ - memfailed
errno           db   "Errno: "
.len            equ   $ - errno


