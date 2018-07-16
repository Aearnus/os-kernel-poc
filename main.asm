[BITS 16]
[ORG 0x0]
[CPU 8086]

start:
    ; clear interrupt flags
    cli

    ; turn on video mode
    mov ah, 0x00 ; Set video mode
    mov al, 0x03 ; 80x25 w/ 16 colors @ address 0xB800
    int 0x10

    ; initialize registers and go
    mov bx, 0
    jmp printchar

printchar:
    mov ah, 0x0E ; teletype output
    mov al, 'a' ; character to print
    mov bh, 0x00 ; page number
    mov bl, 0xF0 ; background (white)/foreground (black)
    int 0x10
    jmp printchar
    
times 510-($-$$) db 0
dw 0xAA55
