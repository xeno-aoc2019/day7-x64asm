; malloc [ptr] size
extern _memalloc

%macro memalloc 2
    mov rax, %2
    call _memalloc
    mov %1, rax
%endmacro