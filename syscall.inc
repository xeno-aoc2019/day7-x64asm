

;; IO

; example: io_open_outfile [fd] filename
%macro io_open_outfile 2
    mov rax, SYS_OPEN
    mov rdi, %2
    mov rsi, O_CREATE_WRITE ;  flags=ro
    mov rdx, 0666o; mode
    syscall
    mov %1, rax
%endmacro

; io_open_infile [fd] filename
%macro io_open_infile 2
    mov rax, SYS_OPEN
    mov rdi, %2 
    mov rsi, O_RDONLY ; flags=ro
    mov rdx, 0        ; mode, not used
    syscall
    mov %1, rax
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

; sys_allocmem [pointer address] bytes
%macro sys_allocmem 2
    mov rax, SYS_MMAP
    xor rdi, rdi ; memory address, 0 = let the system find some
    mov rsi, %2 ; size
    mov rdx, 7 ; RWX 
    mov r10, MAP_ANON_PRIV
    mov r8,  -1 ; fd
    xor r9,  r9 ; offset
    syscall
    mov %1, rax
%endmacro


;;;;; IO CALLS


;;; write

; fprints [fd] buffer length
%macro fprints 3
    mov rax, SYS_WRITE
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro
%macro prints 2  
    fprints FD_STDOUT, %1, %2
%endmacro

%macro fprintln 1
    fprints %1, newline, 1
%endmacro
%macro println 0
    prints newline, 1
%endmacro

;;; read

; freads [fd], buf, length
%macro freads 3
    mov rax, SYS_READ
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro
