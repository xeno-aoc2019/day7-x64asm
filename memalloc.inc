; malloc [ptr] size
%macro memalloc 2
    mov rax, %2
    call _memalloc
    mov %1, rax
%endmacro