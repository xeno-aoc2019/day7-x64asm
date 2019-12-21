%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "printd.inc"
%include "memalloc.inc"

%macro debug_num 1
    mov r10, %1
    prints debug_s, debug_s.len
    printd r10
    println
%endmacro

default rel
global _parsefile
section .text
;; open input file

disp_bytes: ; rax
    push r10
    push r11
    push r12
    xor r10, r10
.loop:
    cmp r10, 8
    je .end
    
    mov r12, rax ; store the value
    mov rdx, rax ;
    and rdx, 255 ; rdx = last byte of rax
    
    cmp rdx, 0
    je .null

    printd rdx
    prints space, 1
    mov rax, r12 ; restore the value
    shr rax, 8 ; <- shift to next byte
    
    inc r10
    jmp .loop
.null:
    prints null, null.len
.end:
    println
    pop r12
    pop r11
    pop r10
    ret


; parsefile rax=input_fd
_parsefile:
    debug_num 10000
    io_open_infile [input_fd], input_fname
    memalloc [input_buf], 1000
    memalloc [output_buf], 1000
    freads [input_fd], [input_buf], 100
    mov [input_size], rax
    mov r12, rax
    prints [input_buf], r12
    println
    debug_num [input_size]
    debug_num 10001
    mov r10, input_buf
    mov r12, [r10]
    mov r12, [r12]
    mov rax, r12
    call disp_bytes 
    debug_num 10002

    debug_num r10
    mov r11, r10
    mov r12, [_0]
    sub r11, r12
    debug_num r11
    mov r10, input_buf
    inc r10
    mov r11, [r10]
    sub r11, r12
    debug_num r11 

.end_of_file:


section .data
input_fd        dq    0x0 ; input file descriptor
input_fname     db    "input.txt",0
input_buf       dq    0x0 ; input parsing buffer
input_iter      dq    0x0 ; pointer while iterating
input_size      dq    0x0 ; size of the last read
output_buf      dq    0x0 ; parsed program
debug_s:        db  "debug: "
.len:           equ   $ - debug_s
newline:        db    0x0a
comma:          db    0x2c
_0              dq    0x30
_9              dq    0x39
space:          db    " "
null:           db    "null"
.len            db    $ - null
