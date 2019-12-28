

memalloc.o: memalloc.asm
	nasm -f macho64 memalloc.asm

parsefile.o: parsefile.asm
	nasm -f macho64 parsefile.asm


printd.o: printd.asm
	nasm -f macho64 printd.asm

main.o: main.asm
	nasm -f macho64 main.asm

main: main.o memalloc.o parsefile.o printd.o vm.o perm.o
	ld -macosx_version_min 10.7.0 -no_pie -lSystem -o main main.o memalloc.o parsefile.o printd.o vm.o perm.o

problem.o: problem.asm
	nasm -f macho64 problem.asm

vm.o: vm.asm
	nasm -f macho64 vm.asm

perm.o: perm.asm
	nasm -f macho64 perm.asm

problem: problem.o printd.o
	ld -macosx_version_min 10.7.0 -no_pie -lSystem -o problem problem.o printd.o

perm: perm.o printd.o
	ld -macosx_version_min 10.7.0 -no_pie -lSystem -o perm perm.o printd.o
