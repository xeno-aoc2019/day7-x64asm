%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "printd.inc"
%include "memalloc.inc"

%define COMMA   44
%define NEWLINE 10
%define ZERO    0x30

%macro debug_num 2 
;    printd r10
    push r10
    push r11
    push rax
    push rdx
    mov r10, %1
    mov r11, %2
    prints debug_s, debug_s.len
    printd r10
    prints space, 1
    printd r11
    println
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
    printd rdx
    jmp .printed
.comma:
    prints comma, 1
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
    pop r10
    pop r11
    pop r12
    ret

process_bytes: ; rax = curr_val, rsi = int
    push r10
    push r11
    push r12    
    xor r10, r10 
    mov r12, 10
    ; r12 = CONST=10
    ; r10 = byte_count
    ; rax = curr_val
    ; rsi = int
    ; rdx = current_char/digit
.loop:
    cmp r10, 8 ; if byte_count = 8 goto end (byte finished)
    je .end
    mov rdx, rsi   ; current_char = int.last_byte
    and rdx, 255 
    debug_num 100, rdx
    cmp rdx, 0     ; if current_char = NULL goto null
    je .null 
    cmp rdx, 10    ; if current_char = NEWLINE goto null
    je .null
    cmp rdx, COMMA ; if current_char = COMMA goto comma
    je .comma
    sub rdx, ZERO ; current_char.int_from_ascii
 
    debug_num 200, rdx

    debug_num 210, rax
    mul r12        ; curr_val = curr_val*10+current_char/digit
    add rax, rdx 
    debug_num 300, rax

    inc r10         ; byte_count++
    shr rsi, 8      ; removing int.last_byte
    jmp .loop       ; continue to next char

.comma:
    mov r11, [output_buf]    ; output_buf[output_iter] = current_val
    mov r12, [output_iter]
    add r11, r12
    mov [r11], rax

    inc r12                  ; output_iter++
    mov [output_iter], r12

    xor rax, rax             ; current_val = 0 (next value)
    inc r10                  ; byte_count++
    jmp .loop                 ; continue to next char

.null:
    mov r11, [output_buf]    ; output_buf[output_iter] = current_val
    mov r12, [output_iter]
    add r11, r12
    mov [r11], rax

    inc r12                  ; output_iter++
    mov [output_iter], r12

    prints null, 2
    println
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
_parsefile:
    io_open_infile [input_fd], input_fname
    memalloc [input_buf], 10000
    memalloc [output_buf], 10000
    freads [input_fd], [input_buf], 15
    mov [input_size], rax
    mov r12, rax
    prints [input_buf], r12
    println
    debug_num 1000, [input_size]

    xor r14, r14 ; r14 = current_val
.loop:

    call next_input ; rax = input.iter.next
    mov r14, rax ; r14 = rax = input
    call disp_bytes  ; displays the bytes of rax
    println

    mov rax, r14
    mov rsi, r14 ; int 
    call process_bytes
    mov r14, rax
    
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
