NASM_FILES = multiboot.o start.o long_mode_start.o 
NASM = nasm -f elf32

C_FILES = c_start.c
C = gcc -fno-pic -fno-pie -nostdlib -c

OUT_KERNEL = kernel.bin

.PHONY: clean run kernel

kernel: $(NASM_FILES) $(C_FILES)
	ld -m elf_i386 -n -o $(OUT_KERNEL) -T link.ld $(NASM_FILES)

clean:
	-rm *.o
	-rm *.bin

run: clean kernel
	qemu-system-x86_64 -kernel $(OUT_KERNEL)

multiboot.o:
	$(NASM) multiboot.asm

start.o:
	$(NASM) start.asm

long_mode_start.o:
	$(NASM) long_mode_start.asm

c_start.o:
	$(C) c_start.c
	