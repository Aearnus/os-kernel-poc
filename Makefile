NASM_FILES = multiboot.o start.o
NASM = nasm -f elf32

OUT_KERNEL = kernel.bin

.PHONY: clean run kernel

kernel: $(NASM_FILES)
	ld -m elf_i386 -n -o $(OUT_KERNEL) -T link.ld $(NASM_FILES)

clean:
	-rm *.o
	-rm *.bin

run: kernel
	qemu-system-x86_64 -kernel $(OUT_KERNEL)


multiboot.o:
	$(NASM) multiboot.asm

start.o:
	$(NASM) start.asm
