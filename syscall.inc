

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

;;;;; IO CALLS


;;; write

; fprints [fd] buffer length
%macro fprints 3
    push rcx
    push rax
    push rdi
    push rsi
    push rdx
    push r8
    push r9
    push r10
    push r11
    mov rax, SYS_WRITE
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rsi
    pop rdi
    pop rax
    pop rcx
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
