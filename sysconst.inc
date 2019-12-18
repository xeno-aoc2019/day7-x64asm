%define SYS_EXIT         0x2000001
%define SYS_READ         0x2000003
%define SYS_WRITE        0x2000004
%define SYS_OPEN         0x2000005
%define SYS_CLOSE        0x2000006
%define SYS_MMAP         0x20000c5

%define EXIT_SUCCESS     0

%define FD_STDIN         0
%define FD_STDOUT        1
%define FD_STDERR        2

%define	O_RDONLY         0x0000  ; open for reading only
%define	O_WRONLY         0x0001  ; open for writing only
%define	O_RDWR	         0x0002  ; open for reading and writing
%define	O_ACCMODE        0x0003  ; mask for above modes

%define PROT_READ        1 ; memory protection for mmap
%define PROT_WRITE       2 ; memory protection for mmap
%define PROT_RW          3 ; memory protection for mmap

%define MAP_SHARED       1    ; memory mapping
%define MAP_PRIVATE      2    ; memory mapping
%define MAP_ANON_PRIV    4098 ; memory mapping, anonymous (not file)
%define MAP_FILE_PRIV    2    ; memory mapping, file

%define O_CREATE_WRITE 0x0201 ; open for write, create

