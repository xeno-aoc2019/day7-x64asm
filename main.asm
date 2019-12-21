%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "printd.inc"
%include "memalloc.inc"

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

start:
    trace 0
    trace -1
    call _parsefile

    io_open_infile [input_fd], input_txt
    jnc cont_0
    handle_error 1, rax
cont_0:
    ; mov [input_fd], rax

    trace 100
    memalloc [input_buf_p], 1000
    ; memalloc [program_p], 1000
    ; jnc cont_1
    ; handle_error 2, rax
; cont_1:    
  ;   freads [input_fd], input_buf_p, 20
 ;   jnc cont_2
;    handle_error 3, rax
; cont_2:

    ; write input_buf_p[...r12]


; cont_3:
 ;   printd r12
 
    io_open_outfile [output_fd], output_txt
    fprints [output_fd], msg, msg.len
    io_close [output_fd]

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
r_rax           dq    "rax: "
r_rdi           dq    "rdi: "
r_rdx           dq    "rdx: "
r_r10           dq    "r10: "
r_r11           dq    "r11: "
r_r12           dq    "r12: "
error_code      dq    0x0
errno           dq    0x0
error_code_lab  db    "error_code: "
errno_lab       db    "errno: "
trace_lab       db    "trace: "
program_p       dq    0x0
program_iter    dq    0x0
 