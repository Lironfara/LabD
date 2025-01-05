extern print_multi

section .data
    numberFormat: db "%d", 10, 0
    stringFormat: db "%s", 10, 0
    x_struct: dw 5
    x_num: dw 0xaa, 1, 2, 0x44, 0x4f

section .bss
    input_buffer resb 600

section .text
    global main
main:
    push ebp
    mov ebp, esp

    ; Call print_multi to print initial values
    lea eax, [x_struct]
    push eax
    call print_multi
    add esp, 4

    mov esp, ebp
    pop ebp
    ret