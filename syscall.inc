%include "sysconst.inc"

;; IO

; example: io_open_outfile [fd] filename
%macro io_open_outfile 2
    mov rax, SYS_OPEN
    mov rdi, %2
    mov rsi, O_CREATE_WRITE ;  flags=ro
    mov rdx, 0666o; mode
    syscall
%endmacro

; example: io_close [fd]
%macro io_close 1
    mov rax, SYS_CLOSE
    mov rdi, %1
    syscall
%endmacro

; example: sys_exit EXIT_SUCCESS
%macro sys_exit 1
    mov rax, SYS_EXIT ; exit
    mov rdi, %1
    syscall
%endmacro