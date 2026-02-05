
[bits 16]
KERNEL_OFFSET equ 0x1000
start:
    mov bp, 0x9000
    mov sp, bp
    call load_kernel
    call switch_to_pm
    jmp $

; ---------------- DISK LOAD ----------------
load_kernel:
    mov bx, KERNEL_OFFSET    ; load address
    mov dh, 15               ; number of sectors
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

disk_load:
    mov ah, 0x02
    mov al, dh
    mov ch, 0
    mov dh, 0
    mov cl, 2
    int 0x13
    jc disk_error
    ret

disk_error:
    jmp $

BOOT_DRIVE db 0
;-------------------------
;--------------Protected-mode-swich------!
switch_to_pm:
    cli
    
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:init_pm
;-------------------------------------------

;-------------code-of-protected-mode----------!
[bits 32]

init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0xb8000
    mov esp, ebp

    call KERNEL_OFFSET

    jmp $
;---------------------------------------------



;----------------GDT-Section------------!
gdt_start:

gdt_null:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end- gdt_start- 1
    dd gdt_start

CODE_SEG equ gdt_code- gdt_start
DATA_SEG equ gdt_data - gdt_start
;--------------------------------
;-----------Padding--------!
times 510-($-$$) db 0
dw 0xaa55
;----------------------------