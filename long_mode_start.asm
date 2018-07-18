[BITS 64]

[SECTION .rodata]
string_to_print:
    db "Hello, from x86-64 bit long mode!", 0

[SECTION .data]
interrupt_descriptor_table:
    ; reference here for entry format
    ; https://wiki.osdev.org/IDT#Structure_AMD64
    ; but for now, let's initialize it _all_ to zero
    times (255 * 16) db 0
.pointer:
    dw $ - interrupt_descriptor_table - 1
    dq interrupt_descriptor_table

[SECTION .text]
%include "macros.asm"

[GLOBAL print_inc]
print_inc:
    mov dword [0xb8000], 0x2f4b2f4f
    iret

[GLOBAL long_mode_start]
[EXTERN stack_top]
long_mode_start:
    ; populate the IDT (for now, any interrupt will just jump to print_inc)
    ; keyboard interrupt
    create_64bit_interrupt_gate interrupt_descriptor_table, 1, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 2, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 3, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 4, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 5, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 6, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 7, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 8, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 9, print_inc, attribute_32bit_ring0_interrupt_gate
    ; create_64bit_interrupt_gate interrupt_descriptor_table, 10, print_inc, attribute_32bit_ring0_interrupt_gate

    ; load up the long mode IDT
    lidt [interrupt_descriptor_table.pointer]

    ; TODO: transfer control to a higher level language
    mov rcx, 0
.print_loop:
    mov al, [string_to_print + rcx]
    mov [0xB8000 + rcx * 2], al
    mov [0xB8001 + rcx * 2], byte 15
    inc rcx
    cmp [string_to_print + rcx], byte 0
    jne .print_loop
    ;call print_inc
.idle_loop:
    jmp .idle_loop
