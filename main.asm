%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "printd.inc"
%include "memalloc.inc"
%include "vm.inc"
%include "perm.inc"

; handle_error error_code errno
%macro handle_error 2
   mov [errno], %2
   mov r12, %1
   mov [error_code], r12
   jmp error_handler
%endmacro

default rel
global start
section .text

;; open input file
extern _fprintd
extern _memalloc
extern _parsefile

load_program:
    call _parsefile
    mov [program_p], rax
    mov [program_size], rcx
    ret

%macro init_vm 1
    push rdx
    push rcx
    push rax
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    mov rcx, [program_size]
    mov rax, program_p
    mov rdx, %1 ; vm_id
    vm_init ; rax = program_p, rcx=program_size, rdx=vm_id
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop rax
    pop rcx
    pop rdx
%endmacro

%macro init_vms 0;
    init_vm 0
    init_vm 1
    init_vm 2
    init_vm 3
    init_vm 4
    dump_vm 0
%endmacro

%macro print_phases 1
    push r15
    mov r15, %1
    prints phase_lab, phase_lab.len
    printd 1
    prints space, 1
    print_hex r15
    println
    pop r15
%endmacro

%macro mov_last_hexdigit 2 ; target, source
    mov %1, %2
    and %1, 0xf
    shr %2, 4
%endmacro


handle_answer: ; rax
    push r15
    push r14
    mov r14, rax
    mov r15, [answer]
    prints result_lab, result_lab.len
    printd r15 ; what was the last value? 
    prints comma, 1
    printd r14 ; what is the current?
    println

    cmp r14, r15
    jna .not_above
    prints result_lab, result_lab.len
    printd r14
    prints space, 1
    printd r14
    println
    mov [answer], rax
.not_above:
    pop r14
    pop r15
    ret

run_vms_with_rax_values:
    ; r15 = phase_values
    ; r13 = current_phase_value
    ; r14 = io_value

    ; set up vm's for running
    push r15
    mov r15, rax ; r15 = phase values
    add r15, 0x55555 ; ([0-4]{5} -> [5-9]{5})
    print_phases r15
    init_vms

    ; setting phase values (r15 = perm(0-4), setting perm(5-9))
    vm_run 0                    ; start vm 0 and initiate with first phase value
    mov_last_hexdigit r13, r15
    vm_set_input 0, r13
    vm_run 1                    ; start vm 1 and initiate with next phase value
    mov_last_hexdigit r13, r15  
    vm_set_input 1, r13
    vm_run 2                    ; start vm 2 and initiate with next phase value
    mov_last_hexdigit r13, r15  
    vm_set_input 2, r13
    vm_run 3                    ; start vm 3 and initiate with next phase value
    mov_last_hexdigit r13, r15  
    vm_set_input 3, r13
    vm_run 4                    ; start vm 4 and initiate with next phase value
    mov_last_hexdigit r13, r15  
    vm_set_input 4, r13

    mov r14, 0

.cycle:
    vm_run 0
    vm_set_input 0, r14
    vm_run 0
    vm_get_output 0, r14

    vm_run 1
    vm_set_input 1, r14
    vm_run 1
    vm_get_output 1, r14

    vm_run 2
    vm_set_input 2, r14
    vm_run 2
    vm_get_output 2, r14
    
    vm_run 3
    vm_set_input 3, r14
    vm_run 3
    vm_get_output 3, r14

    vm_run 4
    vm_set_input 4, r14
    vm_run 4
    vm_get_output 4, r14

    ; check halt and loop

    vm_is_halted 4
    printd 101
    prints colon, 3
    printd rcx
    jrcxz .is_not_halted
    jmp .is_halted
.is_not_halted:
    jmp .cycle
.is_halted:

;    vm_get_output 4, r14
    mov rax, r14
    call handle_answer
    pop r15
    ret

start:
    call load_program
    perm5 run_vms_with_rax_values
    ; mov rax, 0x01234
    ; call run_vms_with_rax_values
    sys_exit EXIT_SUCCESS

error_handler:
    prints error_code_lab, 12
    printd [error_code]
    prints errno_lab, 7
    printd [errno]
    println
    sys_exit EXIT_FAILURE

section .data

msg:            db    "Hello, world!", 10
.len:           equ   $ - msg
input_txt:      db    "input.txt",0
output_txt:     db    "output.txt",0
input_fd:       dq    0x0
output_fd:      dq    0x0
digits:         db    "0123456789_123456789_123456789"
newline:        db    10
comma           db    0x2c
space           db    0x20
zero_chr        db    0x30
hexdigits:      db    "0123456789abcdef***" 
debug_line:     db    "----------",10
failure:        db    "failure",10
success:        db    "success",10
buffer:         db    "____________________________________________________________",10
input_buf_p:    dq    0x0 ; ptr to memory buffer for parsing
input_p         dq    0x0 ; ptr to current pos in parsing
input_buf_read: dq    0x0 ; size of input
input_read_c:   dq    0x0 ; ptr to parsed program
r_rax           db    "rax: "
r_rdi           db    "rdi: "
r_rdx           db    "rdx: "
r_r10           db    "r10: "
r_r11           db    "r11: "
r_r12           db    "r12: "
r_rcx           db    "rcx: "
error_code      dq    0x0
errno           dq    0x0
error_code_lab  db    "error_code: "
errno_lab       db    "errno: "
trace_lab       db    "trace: "
program_p       dq    0x0
program_iter    dq    0x0
program_size    dq    0x0
phase_lab       db    "phase settings: "
.len            equ   $ - phase_lab    
answer          dq    0x0
result_lab      db    "result: "
.len            equ   $ - result_lab 
answer_lab      db    "answer: "
.len            equ   $ - answer_lab
colon          db    "::::::::::::::::"
 