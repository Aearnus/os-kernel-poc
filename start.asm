[BITS 32]

[GLOBAL start]
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

enable_paging:
    ; place the L4 page directory in control register 3
    mov eax, page_l4_directory
    mov cr3, eax

    ; enable Physical Address Extension
    mov eax, cr4

start:
    ; establish the stack pointer
    mov esp, stack_top
    ; we make a few assumptions here:
    ; these assumptions are as follows:
    ; 1. we are running in a multiboot 1 environment
    ; 2. the CPUID opcode is available to us
    ; 3. we are running on an x86_64 CPU
    ; if any of these are false, Bad Things will happen
    ; (qemu-system-x86_64 -kernel <kernel> fufills these assumptions)
    mov [0xB8000], byte 'A'
    mov [0xB8000 + 1], byte 'a'

; thanks to https://os.phil-opp.com/entering-longmode/
; to enter longmode
[SECTION .bss]
ALIGN 4096
; define the stack
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
