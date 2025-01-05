extern print_multi

section .data
    hexa_format db "%02hhx", 0  ; Format string for printf
    input_prompt db "Enter a hexadecimal number: ", 0
    new_line db 10, 0           ; Newline character
    numberFormat: db "%d", 10, 0
    stringFormat: db "%s", 10, 0
    x_struct: dw 5
    x_num:db 0xaa, 1,2, 0x44, 0x4f

section .bss
    input_buffer resb 600

section .text
    global main
    extern printf, fgets, stdin


main:
    ; Call print_multi to print initial values
    lea eax, [x_struct]
    push eax ; we need to pass the address of x_struct
    call print_multi
    add esp, 4
    mov esp, ebp
    pop ebp
    ret


print_multi:
    push ebp
    mov ebp, esp
    push esi ;beause we use it
    push edi ;beause we use it
    push ebx ;beause we use it

    mov esi, [ebp + 8]        ; Load the address of x_struct into eax
    movzx ecx, word [esi]     ; Load array length to ecx
    lea edi, [esi + 2]        ;holds the adress of x_num
    dec ecx

loop:
    cmp ecx, -1               ; Check if ecx is 0
    je end_print_multi        ; If ecx is 0, jump to end_print_multi
    movzx eax, word [edi + ecx * 2] ; Load the value - start at end of array
    push ecx
    push eax
    push hexa_format
    call printf
    add esp, 8
    pop ecx ;to restore the length
    dec ecx
    jmp loop

end_print_multi:
    push new_line
    call printf
    add esp, 4

    pop edi
    pop ecx
    pop eax
    mov esp, ebp
    pop ebp
    ret