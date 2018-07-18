; the three args are this:
; 1: the page table address to create the entry in
; 2: the index that you wanna put it at
; 3: where that damn entry points
; 4: the bitmask to apply (refer to table)
; note: this shit clobbers eax
%macro create_page_table_entry 4
    ; set up the entry in register eax
    mov eax, %3
    or eax, %4
    ; place the entry into the table
    mov [%1 + %2*8], eax
%endmacro


; args:
; 1: the pointer to the IDT
; 2: the interrupt number you want (0-255)
; 3: the 64-bit address to the interrupt handler
; 4: the gate type and attributes (8 bits)
; note: this DOESN'T use the Interrupt Stack Table
; ; https://wiki.osdev.org/IDT#Structure_AMD64
; %macro access_64bit_idt(idt, n) []
%macro create_64bit_interrupt_gate 4
    ; first 16 bits of the handler
    mov rax, %3
    mov [%1 + %2 * 16], ax ; times 16 because each gate is 16 bytes
    ; code selector, telling the CPU that this gate
    ; should get executed in the context of the first
    ; segment in the GDT
    ; (https://wiki.osdev.org/Selector)
    ; (all interrupts run in ring 0)
    ; mov [%1 + %2 * 16 + 2], (global_descriptor_table + 64)
    mov [%1 + %2 * 16 + 2], cs
    ; disable the interrupt stack table
    mov [%1 + %2 * 16 + 4], byte 0
    ; types and attributes (what type of gate is it? what privilege?)
    mov [%1 + %2 * 16 + 5], byte %4
    ; the rest of the handler's bits
    ; first, the second 16 bits
    mov rax, %3
    shr rax, 16
    mov [%1 + %2 * 16 + 6], ax
    ; then the final 32 bits
    mov rax, %3
    shr rax, 32
    mov [%1 + %2 * 16 + 8], eax
    ; the last 32 bits are all just zeroed out/reserved
%endmacro
%define attribute_32bit_ring0_task_gate 0b10010101
%define attribute_32bit_ring0_interrupt_gate 0b10001110
%define attribute_32bit_ring0_trap_gate 0b10001111
