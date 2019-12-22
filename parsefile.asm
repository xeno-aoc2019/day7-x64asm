%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "printd.inc"
%include "memalloc.inc"

%define COMMA   44
%define NEWLINE 10
%define ZERO    0x30

%macro debug_num 2
; noop - so nice and quiet
%endmacro
%macro debug_num_disabled 2 
    push r10
    push r11
    push rax
    push rdx
    push rcx
    mov r10, %1
    mov r11, %2
    prints debug_s, debug_s.len
    printd r10
    prints space, 1
    printd r11
    println
    pop rcx
    pop rdx
    pop rax
    pop r11
    pop r10
%endmacro

; conv:
; RDI, RSI, RDX, RCX, R8, R9 -> RAX

default rel
global _parsefile
section .text
; open input file

disp_bytes: ; rax
    push r10
    push r11
    push r12
    push r13
    push r14
    xor r10, r10
    ; r10 = byte_count
.loop:
    cmp r10, 8   ; if byte_code = 8 goto end
    je .end
    
    mov r12, rax ; store the value
    mov rdx, rax ;
    and rdx, 255 ; rdx = last byte of rax
    
    cmp rdx, 0
    je .null
    cmp rdx, 10 ; newline
    je .null
    cmp rdx, COMMA
    je .comma
    sub rdx, ZERO
    ; printd rdx
    jmp .printed
.comma:
    ; prints comma, 1
    jmp .printed
.printed:
;    prints space, 1
    mov rax, r12 ; restore the value
    shr rax, 8 ; <- shift to next byte
    inc r10
    jmp .loop
.null:
    prints null, 4
.end:
 ;   println
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    ret

program_append: ; rax
    push r10
    push r12
    push r13
    debug_num 5555, rax
    mov r10, output_buf    ; *input = output_buf
    mov r12, [r10]         ; r12 = output_buf.deref
    mov r13, [output_iter] ; load output_iter
    add r12, r13           ;

    add r13, 8             ; output_iter += 8  (save)
    mov [output_iter], r13  ; 

    mov [r12], rax        ; output_iter.deref = rax
    pop r13
    pop r12
    pop r10
    ret

process_bytes: ; rax = curr_val, rcx = int
    push r10
    push r11
    push r12    
    xor r10, r10 
    mov r12, 10
    mov r13, rcx
    ; r12 = CONST=10
    ; r10 = byte_count
    ; rax = curr_val
    ; rsi = int
    ; r13 = current_char/digit
.loop:
    cmp r10, 8     ; if byte_count = 8 goto end (byte finished)
    je .end
;    debug_num 99, rcx
    mov r13, rcx   ; current_char = int.last_byte
    and r13, 255 
    debug_num 100, r13
    cmp r13, 0     ; if current_char = NULL goto null
    je .null 
    cmp r13, 10    ; if current_char = NEWLINE goto null
    je .null
    cmp r13, COMMA ; if current_char = COMMA goto comma
    je .comma
    sub r13, ZERO ; current_char.int_from_ascii
 
    debug_num 200, r13

    debug_num 210, rax
    mul r12        ; curr_val = curr_val*10+current_char/digit
    add rax, r13 
    debug_num 300, rax

    inc r10         ; byte_count++
    shr rcx, 8      ; removing int.last_byte
    jmp .loop       ; continue to next char

.comma:
    debug_num 390, rcx
    debug_num 391, rcx
    ; prints comma, 1
    ; println
    debug_num 393, rcx
    debug_num 400, rax
    call program_append ; rax
    shr rcx, 8
    xor rax, rax             ; current_val = 0 (next value)
    inc r10                  ; byte_count++
    jmp .loop                 ; continue to next char

.null:
    call program_append ; rax
    debug_num 500, rax
    ; println
    mov rax, -1              ; returning -1 for end of file
.end:
    pop r12
    pop r11
    pop r10
    ret

next_input: ; -> rax
    ; r13 = input_iter
    ; r10 = *input
    push r10
    push r12
    push r13
    mov r10, input_buf     ; *input = input_buf
    mov r12, [r10]         ; r12 = input_buf.deref
    mov r13, [input_iter]  ; load input_iter
    add r12, r13           ;

    add r13, 8             ; input_iter += 8  (save)
    mov [input_iter], r13  ; 

    mov r12, [r12]         ; input = input_iter.deref
    mov rax, r12
    pop r13
    pop r12
    pop r10
    ret

get_input: ; index = rax, output = rax
    push r10
    push r12
    mov r10, output_buf
    mov r12, [r10]
    add r12, rax
    mov rax, [r12]
    pop r12
    pop r10
    ret

%macro disp_program 1
    mov rax, %1
    call get_input
    debug_num 300, rax
%endmacro


; parsefile 
_parsefile: ; -> rax=*buffer, rcx=size
    io_open_infile [input_fd], input_fname
    memalloc [input_buf], 100000
    memalloc [output_buf], 100000
    freads [input_fd], [input_buf], 15000
    mov [input_size], rax
    mov r12, rax
    prints [input_buf], r12
    println
    debug_num 1000, [input_size]

    xor r15, r15 ; curr_value = 0
.loop:

    call next_input  ; rax = input.iter.next
    mov r14, rax     ; r14 = rax = input
;    debug_num 1900, rax ; input:int
    call disp_bytes  ; displays the bytes of rax
    ; println

    debug_num 1905, r15 ; input:current_value
    mov rax, r15  ; current_value, starts at 0
    mov rcx, r14  ; int 
;   debug_num 1906, rcx ; again...
;   debug_num 1907, rcx ; again...
;   debug_num 1910, r14
    call process_bytes
;   debug_num 1908, rcx ; again
    mov r15, rax ; current_value
    
    push rax
    debug_num 2000, rax
    pop rax

    cmp rax, -1
    jne .loop

    debug_num 3000, rax ; printing return value from process_bytes
    debug_num 4000, 10003
    disp_program 0
    disp_program 1
    disp_program 2
    disp_program 3
    mov rax, [output_buf]
    mov rcx, [output_iter]
    ret


section .data
input_fd        dq    0x0 ; input file descriptor
input_fname     db    "input.txt",0
input_buf       dq    0x0 ; input parsing buffer
input_iter      dq    0x0 ; pointer while iterating
input_size      dq    0x0 ; size of the last read
output_buf      dq    0x0 ; parsed program
output_iter     dq    0x0 ; pointer while iterating
debug_s:        db  "debug: "
.len:           equ   $ - debug_s
newline:        db    0x0a
comma:          db    0x2c
_0              dq    0x30
_9              dq    0x39
space:          db    " "
null:           db    "null"
.len            db    $ - null
dot:            db    "."
par_end         db    "]"
par_start       db    "["
