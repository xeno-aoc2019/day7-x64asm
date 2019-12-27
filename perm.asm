%include "printd.inc"
%include "sysconst.inc"
%include "syscall.inc"

default rel
global _perm_5_of_0_4, _print_num
section .text

%macro make_bit 2 ; make_bit r9, r10b => r9=2^r10
    push rcx
    mov cl, %2
    mov %1, 1
    shl %1, cl
    pop rcx
%endmacro 

%macro sequence5 6 ; target src1 .. src5
    mov cl, 4
    mov %1, %2
    shl %1, cl
    or %1, %3
    shl %1, cl
    or %1, %4
    shl %1, cl
    or %1, %5
    shl %1, cl
    or %1, %6
%endmacro

%macro encode5 6 ; target reg1 ... reg5
    mov %1, %2
    shl %1, 4
    or %1, %3
    shl %1, 4
    or %1, %4
    shl %1, 4
    or %1, $5
    shl %1, 4
    or %1, $6
%endmacro

start:
    mov rdx, _print_num
    call _perm_5_of_0_4
    sys_exit EXIT_SUCCESS


_print_num: ; <- rax
    push r10
    push r11
    push r12
    push r13
    push r14
    mov r10, rax
    shr r10, 16
    ; and r10, 0xf
    mov r11, rax
    shr r11, 12
    and r11, 0xf
    mov r12, rax
    shr r12, 8
    and r12, 0xf
    mov r13, rax
    shr r13, 4
    and r13, 0xf
    mov r14, rax
    and r14, 0xf
    printd r10
    printd r11
    printd r12
    printd r13
    printd r14
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    ret

_print_5_bits_rev: ; rax
    push r10
    push r9
    push r8
    push rax
    xor r8, r8
.next:
    cmp r8, 5 
    je .exit
    mov r9, rax
    and r9, 1
    push rax
    printd r9
    pop rax
    shr rax, 1
    inc r8
    jmp .next
.exit:
    pop rax
    pop r8
    pop r9
    pop r10
    ret

_perm_5_of_0_4: ; rdx = callback(rax)
    xor r15, r15 ; flags = 00000
    xor r10, r10 ; r10 = 0
.loop1:          ; do (loop1)
 
    make_bit r9, r10b ; r15[r10] = 1
    mov rax, r15
    or r15, r9
    push r9

    xor r11, r11
.loop2:
    make_bit r9, r11b 

    mov r8, r9 ; if r15[r11] is set
    and r8, r15
    cmp r8, 0
    jnz .loop2_end
 
    or r15, r9
    push r9 

    xor r12, r12
.loop3:
    make_bit r9, r12b ; r15[r12] = 1

    mov r8, r9 ; if r15[r11] is set
    and r8, r15
    cmp r8, 0
    jnz .loop3_end

    or r15, r9
    push r9

    xor r13, r13
.loop4:
    make_bit r9, r13b ; r15[r13] = 1
 
    mov r8, r9 ; if r15[r11] is set
    and r8, r15
    cmp r8, 0
    jnz .loop4_end

    or r15, r9
    push r9

    xor r14, r14
.loop5:
    make_bit r9, r14b ; r15[r14] = 1

    mov r8, r9 ; if r15[r11] is set
    and r8, r15
    cmp r8, 0
    jnz .loop5_end

    or r15, r9
    push r9

 ;   call rdx
 ;   prints values_lab, values_lab.len
    push rdx
    push rax
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    sequence5 rax, r10, r11, r12, r13, r14
    ; call _print_num
    ; println
    call rdx
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rax
    pop rdx

.skip:

    pop r9
    xor r15, r9 ; r15[r14] = 0
.loop5_end:

    inc r14 ; loop3: while r11 != 5
    cmp r14, 5
    jne .loop5

    pop r9
    xor r15, r9 ; r15[r13] = 0
.loop4_end:

    inc r13 ; loop3: while r11 != 5
    cmp r13, 5
    jne .loop4

    pop r9
    xor r15, r9 ; r15[r12] = 0
.loop3_end:

    inc r12 ; loop3: while r11 != 5
    cmp r12, 5
    jne .loop3

    pop r9
    xor r15, r9 ; r15[r11] = 0
.loop2_end:

    inc r11 ; loop2: while r11 != 5
    cmp r11, 5
    jne .loop2

.loop1_end:
    pop r9
    xor r15, r9 ; r15[r10 = 0]

    inc r10      ; loop1: while r10 != 5
    cmp r10, 5
    jne .loop1

    ret


section .data
digits          db    "0123456789abcdef"
newline         db    0x0a
space           db    " "
values_lab      db    "values: "
.len            equ   $ - values_lab
calling_lab     db    "calling: "
.len            equ   $ - calling_lab