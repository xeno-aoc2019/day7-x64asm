extern _fprintd

%macro fprintd 2 ; [fd] mum
    mov rdi, %1
    mov rax, %2
    call _fprintd
%endmacro

%macro printd 1 ; num
    mov rdi, 1
    mov rax, %1
    call _fprintd
%endmacro

