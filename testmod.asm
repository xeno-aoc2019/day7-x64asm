%include "sysconst.inc"
%include "syscall.inc"

%include "debug.inc"
%include "writenum.inc"

; handle_error error_code errno

default rel
global testprint
section .text
;; open input file

testprint:
    prints msg, msg.len
    println
    ret

section .data

msg:            db    "Hello, test!", 10
.len:           equ   $ - msg
newline:        db    10
