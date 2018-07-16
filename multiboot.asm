[BITS 32]

; this section is compatible with the multiboot 1 spec
; https://www.gnu.org/software/grub/manual/multiboot/multiboot.html
[SECTION .multiboot_header]
multiboot_header_begin:
    ; magic number
    dd 0x1BADB002
    ; flags
    dd 0
    ; checksum
    dd -(0x1BADB002 + 0)
multiboot_header_end:

; ; this section is compatible with the multiboot 2 spec
; ; http://nongnu.askapache.com/grub/phcoder/multiboot.pdf
; [SECTION .multiboot_header]
; multiboot_header_begin:
;     ; magic number
;     dd 0xE85250D6
;     ; arch 0 (i386)
;     dd 0
;     ; header length
;     dd (multiboot_header_end - multiboot_header_begin)
;     ; checksum
;     dd 0x100000000 - (0xE85250D6 + 0 + (multiboot_header_end - multiboot_header_begin))
;     ; begin multiboot tags
;     ; required end tag
;     dw 0
;     dw 0
;     dd 8
;     ; end multiboot tags
; multiboot_header_end:
