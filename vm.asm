
%include "memalloc.inc"
%include "printd.inc"
%include "sysconst.inc"
%include "syscall.inc"

default rel
global _vm_init
section .text

get_opcode: ; rdx:rax -> rax (rdx=vm id, rax=index)
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

copy_program: ; rax = vm id (0-4), rcx = program size
    push r15
    shl rax, 3 ; rax = rax * 8 (vm id to byte offset)
    mov r15, rax ; r15 = byte offset
    printd r15
    println
    mov r13, rcx ; r13 = program_size
    lea r10, [rel program_p]
    add r10, r15 ; r10 = program_p[r15]
    printd r10
    println
    memalloc [r10], r13 
    ;printd r10
    ;println
    xor r11, r11
    mov r12, 0
.loop:
    mov rax, [orig_program_p]
    lea r14, [rel program_p]
    add r14, r15
    ;printd rax
    ;prints colon, 1
    ;printd r14
    ;println
    ; add r14, r15    
    mov r14, [r14]
 ;   printd r15
 ;   println
 ;   add r14, r15
    mov rax, [rax]
;    mov r14, [r14]
    add rax, r12
    add r14, r12
    mov rdx, [rax]
    printd rdx
    prints colon,1
    printd r14
    prints space,1
    mov [r14], rdx
    cmp r12, r13
    je .done
    add r12, 8
    jmp .loop
.done:
    println
    pop r15
    ret


_vm_init: ; rax = *vm, *rcx = *size
    mov [orig_program_p], rax
    mov [program_size], rcx
    printd rax
    println
  ;  xor rax, rax ; vm = 0
    mov rax, 1 ; vm = 1
    call copy_program
 ;   mov rax, -  ; vm = 1
 ;   call copy_program
    
;    xor rax,rax
    mov rdx, 1
    mov rax, 2
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
s_get_opcode        db  "get opcode",10
.len                equ $ - s_get_opcode