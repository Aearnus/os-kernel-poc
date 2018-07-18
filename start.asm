[BITS 32]

; text section = code
[SECTION .text]
%include "macros.asm"

page_tables_identity_map_1gb:
    ; link page directory to page table w/ offset 0
    ; bitmask here = entry is present & writable
    create_page_table_entry page_l4_directory, 0, page_directory, 0b11
    ; link page directory to page table w/ offset 0
    create_page_table_entry page_directory, 0, page_table, 0b11
    ; next, map every entry in the deepest page table to huge tables in physical memory
    ; this causes the first 1gb of memory to be identity mapped,
    ; that is: any address in virtual address space will be the same as the address
    ; in physical address space within the first gb (512 entries * 2mb per entry)
    mov ecx, 0
.loop_populate_deep_table:
    ; put the destination address into eax
    ; each page is 2mb (since they're huge pages),
    ; so we increment by 0x200000 each time
    mov eax, 0x200000
    mul ecx
    ; add the entry with a bitmask saying it's present, writable, and huge
    ; (this macro uses eax, and the first argument will be a noop (mov eax, eax))
    create_page_table_entry page_table, ecx, eax, 0b10000011
    ; repeat the loop 512 times
    inc ecx
    cmp ecx, 512
    jle .loop_populate_deep_table

    ret ; from .page_tables_identity_map_1gb

enable_long_mode_paging:
    ; place the L4 page directory in control register 3
    mov eax, page_l4_directory
    mov cr3, eax
    ; enable Physical Address Extension by flipping bit 5 in
    ; control register 4
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
    ; enable long mode in the Extended Feature Enable Register by flipping bit 8
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    ; enable paging in control register 0 by flipping bit 31
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

; this is the all inclusive function to enable long mode just like that
enable_long_mode:
    ; do everything necessary for paging
    call page_tables_identity_map_1gb
    call enable_long_mode_paging
    ; set up Global Descriptor Table to enable 64 bit opcodes
    lgdt [global_descriptor_table.pointer]

    ret

[GLOBAL start]
[EXTERN long_mode_start]
start:
    ; establish the stack pointer
    mov esp, stack_top
    ; we make a few assumptions here:
    ; these assumptions are as follows:
    ; 1. we are running in a multiboot 1 environment
    ; 2. the CPUID opcode is available to us
    ; 3. we are running on an x86_64 CPU
    ; if any of these are false, Bad Things will happen
    ; (your CPU will fault repeatedly and probably catch on fire)
    ; (qemu-system-x86_64 -kernel <kernel> fufills these assumptions)

    ; let's enable long mode
    call enable_long_mode
    ; then we have to long jump to some 64 bit code & begin!
    jmp dword 0x8:long_mode_start

; thanks to https://os.phil-opp.com/entering-longmode/
; to enter longmode
; bss section = uninitialized data
[SECTION .bss]
ALIGN 4096
; define the stack
[GLOBAL stack_top]
[GLOBAL stack_bottom]
stack_bottom:
    resb 8192
stack_top:
; define the identity pagetables
page_l4_directory:
    resb 4096
page_directory:
    resb 4096
page_table:
    resb 4096

; rodata section = read only data
[SECTION .rodata]
global_descriptor_table:
    ; mandatory 0 entry
    dq 0
    ; set as code segment, ' ', set as present, set as 64-bit
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53)
.pointer:
    dw $ - global_descriptor_table - 1
    dd global_descriptor_table
