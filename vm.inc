extern _vm_init
extern _vm_get_opcode
extern _vm_set_opcode
extern _vm_run

%macro vm_init 0
    call _vm_init
%endmacro

%macro vm_get_opcode 2
    mov rdx, %1
    mov rax, %2
    call _vm_get_opcode
%endmacro

%macro vm_set_opcode 3
    mov rdx, %1
    mov rax, %2
    mov rcx, %3
    call _vm_set_opcode
%endmacro

%macro vm_run 1
    mov rdx, %1
    call _vm_run
%endmacro