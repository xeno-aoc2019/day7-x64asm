
%include "memalloc.inc"
%include "printd.inc"
%include "sysconst.inc"
%include "syscall.inc"

default rel
global _vm_init
section .text

get_opcode: ; rax -> rax
    push r14
    mov r14, 8
    mul r14 ; rax = rax*8
    printd rax
    println
    mov r14, [program_p]
    add r14, rax
    mov r14, [r14]
    printd 20000
    prints colon, 1
    printd r14
    println
    mov rax, r14 ; returning rax
    pop r14
    ret

copy_program: ; rax = vm id (0-4), rcx = program size
    push r15
    mov r15, 8
    mul r15 ; rax = rax * 8 (vm id to byte offset)
    mov r15, rax ; r15 = byte offset
    printd r15
    println
    mov r13, rcx ; r13 = program_size
    lea r10, [rel program_p]
 ;   add r10, r15 ; r10 = program_p[r15]
    memalloc [program_p], r13 
    xor r11, r11
    mov r12, 0
.loop:
    mov rax, [orig_program_p]
    mov r14, [program_p]
    mov rax, [rax]
;    mov r14, [r14]
    add rax, r12
    add r14, r12
    mov rdx, [rax]
    mov [r14], rdx
    cmp r12, r13
    je .done
    add r12, 1
    jmp .loop
.done:
    pop r15
    ret


_vm_init: ; rax = *vm, *rcx = *size
    mov [orig_program_p], rax
    mov [program_size], rcx
    printd rax
    println
    xor rax, rax ; rax = 0 (vm id)
    call copy_program
    xor rax, rax
    add rax, 1
    call get_opcode
    ret

section .data
orig_program_p:     dq  0x0 ; there's only one original program
program_p           dq  0x0,0x0,0x0,0x0,0x0 ; but 5 copies
program_size:       dq  0x0 ; all of the same size

newline             db  10
space               db  0x20
equal               db  "="
colon               db  ":"