[BITS 64]

[SECTION .text]
[GLOBAL long_mode_start]
long_mode_start:
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
    hlt

[SECTION .rodata]
string_to_print:
    db "Hello, from x86-64 bit long mode!", 0

interrupt_descriptor_table: 
    ; reference here for entry format
    ; https://wiki.osdev.org/IDT#Structure_AMD64
    ; but for now, let's initialize it _all_ to zero
    times (255 * 16) db 0
.pointer:
    dw $ - interrupt_descriptor_table - 1
    dq interrupt_descriptor_table