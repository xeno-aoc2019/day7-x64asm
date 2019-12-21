%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "writenum.inc"

; handle_error error_code errno

default rel
global testprint
section .text
;; open input file

; parsefile rax=input_fd
parsefile:


section .data
input_fd        dq    0x10
output_buf      dq    0x10
msg:            db    "Hello, test!", 10
.len:           equ   $ - msg
newline:        db    0x0a
comma:          db    0x2c
_0              db    0x30
_9              db    0x39
