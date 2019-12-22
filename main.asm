%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "printd.inc"
%include "memalloc.inc"
%include "vm.inc"

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
    mov rcx, [program_size]
    mov rax, program_p
    mov rdx, %1 ; vm_id
    vm_init ; rax = program_p, rcx=program_size, rdx=vm_id
%endmacro

start:
    call load_program
    init_vm 0
    init_vm 1
    init_vm 2
    init_vm 3
    init_vm 4

    vm_run 0
    vm_set_input 0, 4
    vm_run 0
    vm_set_input 0, 0
    vm_run 0
    vm_get_output 0, r14
    vm_run 1
    vm_set_input 1, 3
    vm_run 1
    vm_set_input 1, r14
    vm_run 1
    vm_get_output 1, r14
    vm_run 2
    vm_set_input 2, 2
    vm_run 2
    vm_set_input 2, r14
    vm_run 2
    vm_get_output 2, r14
    vm_run 3
    vm_set_input 3, 1
    vm_run 3
    vm_set_input 3, r14
    vm_run 3
    vm_get_output 3, r14
    vm_run 4
    vm_set_input 4, 0
    vm_run 4
    vm_set_input 4, r14
    vm_run 4
    vm_get_output 0, r14
    printd r14
    println
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
 