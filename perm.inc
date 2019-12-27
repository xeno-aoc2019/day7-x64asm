
extern _perm_5_of_0_4
extern _print_num

%macro perm5 1; perm5 callback(rax)
    push rdx
    push rax
    mov rdx, %1
    call _perm_5_of_0_4
    pop rax
    pop rdx
%endmacro

%macro print_hex 1
    push rax
    mov rax, %1
    call _print_num
    pop rax
%endmacro
