extern _vm_init
extern _vm_get_opcode

%macro vm_init 0
    call _vm_init
%endmacro

%macro vm_get_opcode 2
    mov rdx, %1
    mov rax, %2
    call _vm_get_opcode
%endmacro