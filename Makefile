

memalloc.o: memalloc.asm
	nasm -f macho64 memalloc.asm

parsefile.o: parsefile.asm
	nasm -f macho64 parsefile.asm


printd.o: printd.asm
	nasm -f macho64 printd.asm

main.o: main.asm
	nasm -f macho64 main.asm

main: main.o memalloc.o parsefile.o printd.o
	ld -macosx_version_min 10.7.0 -no_pie -lSystem -o main main.o memalloc.o parsefile.o printd.o