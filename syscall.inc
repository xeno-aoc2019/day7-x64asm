%include "sysconst.inc"

%macro io_open_outfile 2
    mov rax, SYS_OPEN
    mov rdi, %2
    mov rsi, O_CREATE_WRITE ;  flags=ro
    mov rdx, 0666o; mode
    syscall
%endmacro

; io_open_outfile [output_fd] outfile
