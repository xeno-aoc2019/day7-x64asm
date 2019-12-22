
%include "memalloc.inc"
%include "printd.inc"
%include "sysconst.inc"
%include "syscall.inc"

default rel
global _vm_init, _vm_get_opcode, _vm_set_opcode, _vm_run, _vm_is_iowait,\
       _vm_set_input, _vm_get_output
section .text

%define VM_IP       4000
%define VM_HALTED   4001
%define VM_IOWAIT   4002
%define VM_ERR      4003
%define VM_INPUT    4004
%define VM_INPUT_F  4005
%define VM_OUTPUT   4006
%define VM_OUTPUT_F 4007

%define I_ADD     1
%define I_MUL     2
%define I_INPUT   3
%define I_OUTPUT  4
%define I_JT      5
%define I_JF      6
%define I_LT      7
%define I_EQ      8
%define I_HALT    99

%macro to_instr 1 ; reg: convert registry to instr
    push rcx
    push rdx
    push rax
    mov rcx, 100
    xor rdx, rdx
    mov rax, %1
    div rcx
    mov %1, rdx
    pop rax
    pop rdx
    pop rcx
%endmacro

%macro vm_set_opcode 3
    push rdx
    push rax
    push rcx
    mov rdx, %1
    mov rax, %2
    mov rcx, %3
    call _vm_set_opcode
    pop rcx
    pop rax
    pop rdx
%endmacro

%macro vm_get_opcode 3
    push rdx
    mov rdx, %1
    mov rax, %2
    call _vm_get_opcode
    mov %3, rax
    pop rdx
%endmacro

; getmacro vm-id, instr, flag#, param_adr, (output-reg;)
%macro get_param 5 ;
    push rdx
    push rdi
    push rax
    push rcx
    mov rdi, %1
    mov rax, %2
    mov rsi, %3
    mov rcx, %4
    call _vm_get_param
    mov %5, rax
    pop rcx
    pop rax
    pop rdi
    pop rdx
%endmacro

_dump_vm: ;rdx = vm_id
    push r15
    push r14
    push r13
    mov r15, rdx
    prints s_vm, s_vm.len
    printd r15
    println
    mov r14, [program_size]
    shr r14, 3 ; byte to i64
    printd r14
    println
    xor r13, r13
.loop:
    cmp r14,r13
    je .program_end
    vm_get_opcode r15, r13, r12
    ; printd r13
    ; prints colon,1
    printd r12
    prints space, 1
    inc r13
    jmp .loop
.program_end:
    println
    prints s_ip, s_ip.len
    vm_get_opcode r15, VM_IP, r13
    printd r13
    println
    pop r13
    pop r14
    pop r15
    ret

_vm_get_opcode: ; rdx:rax -> rax (rdx=vm id, rax=index)
    push r14
    push r15
    mov r15, rax
    shl rdx, 3 ; rdx = rdx * 8
    shl r15, 3 ; rax = rax * 8
    lea r14, [rel program_p]
    add r14, rdx
    mov r14, [r14]
    add r14, r15
    mov r14, [r14]
    mov rax, r14 ; returning rax
    pop r15
    pop r14
    ret

_vm_set_opcode: ;rdx:rax=rcx
    push r14
    push r15
    mov r15, rax
    shl rdx, 3 ; rdx = rdx * 8
    shl r15, 3 ; rax = rax * 8
    lea r14, [rel program_p]
    add r14, rdx
    mov r14, [r14]
    add r14, r15
    mov [r14], rcx
    pop r15
    pop r14
    ret

_vm_set_input: ; rdx = vm_id, rax = input
    mov rcx, rax
    mov rax, VM_INPUT
    call _vm_set_opcode
    mov rax, VM_INPUT_F
    mov rcx, 0x1
    call _vm_set_opcode
    ret

_vm_get_input: ; rdx = vm_id -> rax = output, cf=error
    mov rax, VM_INPUT_F
    call _vm_get_opcode
    mov rcx, rax
    jrcxz .no_output
    mov rax, VM_OUTPUT
    call _vm_get_opcode
    clc
    ret
.no_output:
    stc
    ret

_vm_get_output: ; rdx = vm_id -> rax = output, cf=error
    mov rax, VM_OUTPUT_F
    call _vm_get_opcode
    mov rcx, rax
    jrcxz .no_output
    mov rax, VM_OUTPUT
    call _vm_get_opcode
    clc
    ret
.no_output:
    stc
    ret

_vm_is_iowait: ; rdx = vm_id -> rcx
    vm_get_opcode rdx, VM_IOWAIT, rcx
    ret

copy_program: ; rax = vm id (0-4), rcx = program size
    push r15
    shl rax, 3 ; rax = rax * 8 (vm id to byte offset)
    mov r15, rax ; r15 = byte offset
    mov r13, rcx ; r13 = program_size
    lea r10, [rel program_p]
    add r10, r15 ; r10 = program_p[r15]
    memalloc [r10], 100000 ; r13 for the program, but registers at the end
    xor r11, r11
    mov r12, 0
.loop:
    mov rax, [orig_program_p]
    lea r14, [rel program_p]
    add r14, r15
    mov r14, [r14]
    mov rax, [rax]
    add rax, r12
    add r14, r12
    mov rdx, [rax]
    mov [r14], rdx
    cmp r12, r13
    je .done
    add r12, 8
    jmp .loop
.done:
    pop r15
    ret

_vm_get_param: ; rdx=vm id, rax=instruction, rsi=param#, rcx=param_adr -> rax
    push r15
    push r13
    push r11
    push r9
    mov r15, rdx
    mov r11, rcx
    xor rdx, rdx
    ; rdx:rax = instr
    cmp rsi, 1
    je .param1
    cmp rsi, 2
    je .param2
    cmp rsi, 3
    je .param3
    printd 32202
    prints comma, 1
    printd rsi
    println
    mov r13, 0 ; causes a division by zero
    jmp .selected
.param1:
    mov r13, 100
    jmp .selected
.param2:
    mov r13, 1000
    jmp .selected
.param3:
    mov r13, 10000
    jmp .selected
.selected:
    xor rdx, rdx
    ; rax=instruction, so rdx:rax can be divided
    div r13
    xor rdx, rdx ; rdx:rax = remainer:value
    mov r13, 10
    div r13 ; rdx:rax / 10, rdx will have the flag
    mov rcx, rdx ; rcx = zero if flag not set (reference)
    ; fetch the immediate value
    vm_get_opcode r15, r11, r9
    mov rcx, rdx
    jrcxz .reference
    jmp .retvalue
.reference:    
    vm_get_opcode r15, r9, r9 ; dereference
    jmp .end
.retvalue:
.end:
    mov rax, r9 ; return rax = r9
    pop r9
    pop r11
    pop r13
    pop r15
    ret

_vm_init: ; rax = *program, *rcx = *size, rdx = vm id
    mov [orig_program_p], rax
    mov [program_size], rcx
    mov r15, rdx
    printd rax
    println
    mov rax, r15 ; vm = 1
    call copy_program   
    vm_set_opcode r15, VM_IP, 0
    vm_set_opcode r15, VM_HALTED, 0
    vm_set_opcode r15, VM_IOWAIT, 0
    vm_set_opcode r15, VM_ERR, 0
    vm_set_opcode r15, VM_INPUT_F, 0
    vm_set_opcode r15, VM_OUTPUT_F, 0
    ret

_vm_run: ; rdx = vm_id
    ; r15 = vm
    ; r12 = ip
    ; r13 = instruction
    ; r14 = index
    mov r15, rdx
    vm_set_opcode rdx, VM_IOWAIT, 0
.next:
    mov rdx, r15
    call _dump_vm
    vm_get_opcode rdx, VM_IP, r12
    vm_get_opcode rdx, r12, r13
    prints s_ip, s_ip.len
    printd r12
    prints colon, 1
    printd r13
    println
    mov r10, r13
    to_instr r10
    printd 7770
    prints colon,1
    prints colon,1
    printd r13
    prints colon,1
    printd r10
    println
    cmp r10, I_ADD
    je .i_add
    cmp r10, I_MUL
    je .i_mul
    cmp r10, I_INPUT
    je .i_input
    cmp r10, I_OUTPUT
    je .i_output
    cmp r10, I_JT
    je .i_jt
    cmp r10, I_JF
    je .i_jf
    cmp r10, I_LT
    je .i_lt
    cmp r10, I_EQ
    je .i_eq
    cmp r10, I_HALT
    je .i_halt
    prints s_unknown_instr, s_unknown_instr.len
    printd r10
    println
    vm_set_opcode rdx, VM_ERR, 1
    ret
    ; ... and if we're still here, somethings wrong
.i_add:
    printd 7001
    prints colon, 1
    printd r12
    println
    mov r11, r12
    inc r11
    ; rdx=vm id, rax=instruction, rsi=param#, rcx=param_adr -> rax
    get_param r15, r13, 1, r11, r8
    inc r11
    get_param r15, r13, 2, r11, r9
    inc r11
    ; target not dereferencable
    vm_get_opcode r15, r11, r10
    add r9, r8
    vm_set_opcode r15, r10, r9
    printd r8
    prints comma, 1
    printd r9
    prints comma, 1
    printd r10  
    println
    inc r11
    vm_set_opcode r15, VM_IP, r11
    jmp .next
.i_mul:
    printd 7002
    println
    mov r11, r12
    inc r11
    get_param r15, r13, 1, r11, r8
    inc r11
    get_param r15, r13, 2, r11, r9
    inc r11
    ; #3 is not dereferencable
    vm_get_opcode r15, r11, r10
    push rax
    push rdx
    xor rdx, rdx
    mov rax, r9
    mul r8
    mov r9, rax
    pop rdx
    pop rax
;    add r9, r8
    vm_set_opcode r15, r10, r9
    printd r8
    prints comma, 1
    printd r9
    prints comma, 1
    printd r10  
    println
    inc r11
    vm_set_opcode r15, VM_IP, r11
    jmp .next
.i_input:
    vm_get_opcode r15, VM_INPUT_F, rcx
    jrcxz .i_input_missing
    vm_set_opcode r15, VM_INPUT_F, 0 ; consuming the input
    vm_get_opcode r15, VM_INPUT, rcx
    inc r11
    vm_get_opcode r15, r11, r8
    vm_set_opcode r15, r8, rcx
    inc r11
    vm_set_opcode r15, VM_IP, r11
    jmp .next
.i_input_missing:
    vm_set_opcode r15, VM_IOWAIT, 1 ; waiting for input
    ret ; exit, will resume when called again
.i_output:
    inc r11
    get_param r15, r13, 1, r11, r8
    vm_set_opcode r15, VM_OUTPUT, r8
    vm_set_opcode r15, VM_OUTPUT_F, 1
    inc r11
    vm_set_opcode r15, VM_IP, r11
    jmp .next  
.i_jt:
    inc r11
    get_param r15, r13, 1, r11, r8
    inc r11
    get_param r15, r13, 2, r11, r9
    cmp r8, 0x0
    jz .i_jt_not
    vm_set_opcode r15, VM_IP, r9
    jmp .next
.i_jt_not:
    inc r11
    vm_set_opcode r15, VM_IP, r11
    jmp .next
.i_jf:
    inc r11
    get_param r15, r13, 1, r11, r8
    inc r11
    get_param r15, r13, 2, r11, r9
    cmp r9, 0x0
    jnz .i_jf_not
    vm_set_opcode r15, VM_IP, r9
    jmp .next
.i_jf_not:
    inc r11
    vm_set_opcode r15, VM_IP, r11
    jmp .next
.i_lt:
    mov r11, r12
    inc r11
    get_param r15, r13, 1, r11, r8
    inc r11
    get_param r15, r13, 2, r11, r9
    inc r11
    ; #3 is not dereferencable
    vm_get_opcode r15, r11, r10
    sub r9, r8
    and r9, 2<<63
    cmp r9,0
    je .i_lt_notless
    vm_set_opcode r15, r10, 0
    jmp .i_lt_done
.i_lt_notless:
    vm_set_opcode r15, r10, 1
.i_lt_done:
    inc r11
    vm_set_opcode r15, VM_IP, r11
    jmp .next
.i_eq:
    mov r11, r12
    inc r11
    get_param r15, r13, 1, r11, r8
    inc r11
    get_param r15, r13, 2, r11, r9
    inc r11
    ; #3 is not dereferencable
    vm_get_opcode r15, r11, r10
    cmp r8,r9
    je .i_eq_eq
    vm_set_opcode r15, r10, 0
    jmp .i_eq_done
.i_eq_eq:
    vm_set_opcode r15, r10, 1
.i_eq_done:
    inc r11
    vm_set_opcode r15, VM_IP, r11
    jmp .next
.i_halt:
    vm_set_opcode r15, VM_HALTED, 0x1
    vm_get_opcode r15, 0x0, r15
    printd 9999
    prints colon, 1
    printd r15
    println
    ret

section .data
orig_program_p:     dq  0x0 ; there's only one original program
program_p           dq  0x0,0x0,0x0,0x0,0x0 ; but 5 copies
program_size:       dq  0x0 ; all of the same size

newline             db  10
space               db  0x20
equal               db  "="
colon               db  ":"
s_get_opcode        db  "get opcode",10
.len                equ $ - s_get_opcode
s_unknown_instr     db  "Unknown instruction: "
.len                equ $ - s_unknown_instr
comma               db  ","
s_ip                db  "ip: "
.len                equ $ - s_ip
s_i_input           db  "input: "
.len                equ $ - s_i_input
s_i_jt              db  "jt: "
.len                equ $ - s_i_jt
s_i_jf              db  "jf: "
.len                equ $ - s_i_jf
s_vm                db  "vm: "
.len                equ $ - s_vm
