extern _vm_init
extern _vm_get_opcode
extern _vm_set_opcode
extern _vm_run
extern _vm_set_input
extern _vm_get_output
extern _vm_is_iowait
extern _vm_is_halted

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

%macro vm_set_input 2
    push rdx
    mov rdx, %1
    mov rax, %2
    call _vm_set_input
    pop rdx
%endmacro

%macro vm_get_output 2 ; vm_id, output_reg
    mov rdx, %1
    call _vm_get_output ; rdx = vm_id -> rax = output, cf=error
    mov %2, rax
%endmacro

%macro vm_is_iowait 1
    push rdx
    mov rdx, %1
    call _vm_is_iowait
    pop rdx
%endmacro

%macro vm_is_halted 1
    push rdx
    mov rdx, %1
    call _vm_is_halted
    pop rdx
%endmacro

%macro vm_run 1
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    push rax
    push rcx
    push rdx
    mov rdx, %1
    call _vm_run
    pop rdx
    pop rcx
    pop rax
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
%endmacro