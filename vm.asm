
%include "memalloc.inc"
%include "printd.inc"
%include "sysconst.inc"
%include "syscall.inc"

default rel
global _vm_init, _vm_get_opcode, _vm_set_opcode, _vm_run
section .text

%define VM_IP     400
%define VM_HALTED 401
%define VM_IOWAIT 402
%define VM_ERR    403

%define I_ADD     1
%define I_MUL     2
%define I_INPUT   3
%define I_OUTPUT  4
%define I_JT      5
%define I_JF      6
%define I_LT      7
%define I_EQ      8
%define I_HALT    99

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

copy_program: ; rax = vm id (0-4), rcx = program size
    push r15
    shl rax, 3 ; rax = rax * 8 (vm id to byte offset)
    mov r15, rax ; r15 = byte offset
    mov r13, rcx ; r13 = program_size
    lea r10, [rel program_p]
    add r10, r15 ; r10 = program_p[r15]
    memalloc [r10], 2000 ; r13 for the program, but registers at the end
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
    ret

_vm_run: ; rdx = vm_id
    ; r15 = vm
    ; r12 = ip
    ; r13 = instruction
    ; r14 = index
    mov r15, rdx
    vm_set_opcode rdx, VM_IOWAIT, 0
.next:
    vm_get_opcode rdx, VM_IP, r12
    vm_get_opcode rdx, r12, r13
    prints s_ip, s_ip.len
    printd r12
    prints colon, 1
    printd r13
    println
    cmp r13, I_ADD
    je .i_add
    cmp r13, I_MUL
    je .i_mul
    cmp r13, I_INPUT
    je .i_input
    cmp r13, I_OUTPUT
    je .i_output
    cmp r13, I_JT
    je .i_jt
    cmp r13, I_JF
    je .i_jf
    cmp r13, I_LT
    je .i_lt
    cmp r13, I_EQ
    je .i_eq
    cmp r13, I_HALT
    je .i_halt
    prints s_unknown_instr, s_unknown_instr.len
    printd r13
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
    vm_get_opcode r15, r11, r8
    vm_get_opcode r15, r8, r8
    inc r11
    vm_get_opcode r15, r11, r9
    vm_get_opcode r15, r9, r9
    inc r11
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
    vm_get_opcode r15, r11, r8
    vm_get_opcode r15, r8, r8
    inc r11
    vm_get_opcode r15, r11, r9
    vm_get_opcode r15, r9, r9
    inc r11
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

.i_output:

.i_jt:

.i_jf:

.i_lt:

.i_eq:

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