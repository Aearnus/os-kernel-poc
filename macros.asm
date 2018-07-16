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
