extern print_multi
; 0xaa, 1,2,0x44,0x4f
; aa12444f -> 4f 44 12 aa

section .bss
    x_num resw 600
    x_struct resw 1
    input_buffer resb 600
    
section .data
    hexa_format db "%02hhx", 0  ; Format string for printf
    input_prompt db "Enter a hexadecimal number: ", 0
    new_line db 10, 0           ; Newline character
    numberFormat: db "%d", 10, 0
    charFormat: db "%c", 0

    
section .text
    global main
    extern printf, fgets, stdin, stdio


main:
    push ebp
    mov ebp, esp
    call getmulti
    ret


print_multi:
    push ebp
    mov ebp, esp
    push esi ;beause we use it
    push edi ;beause we use it
    push ecx ;beause we use it
    mov edi, x_num

loop:
    cmp ecx, 0               ; Check if ecx is 0
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
    pop ecx
    pop edi
    pop esi
    mov esp, ebp ;the last used function "fix" the stack
    pop ebp ;this is the last function that is called, so it pops ebp
    ret

getmulti:
    push ebp ;this is the first function that is called, so it pushes ebp
    mov ebp, esp
    push input_prompt ;push "Enter a hexadecimal number: "
    call printf ;print the prompt
    add esp, 4

    ;read user input
    lea eax, [input_buffer]
    push dword [stdin]
    push 600
    push eax
    call fgets ;read the input of size maximum 600 into eax
    add esp, 12 
    mov esi, eax
    mov ecx, 0

calculate_length:
    movzx edi, byte [esi + ecx]
    cmp edi, 10 ;for new line
    je save_to_x_struct
    inc ecx
    jmp calculate_length


save_to_x_struct:
    shr ecx, 1 ;divide by 2
    mov word [x_struct], cx ;save the length
    dec ecx
    jmp save_to_x_num

save_to_x_num:
    cmp ecx, 0
    je call_print_multi
    call convert_to_hex
    dec ecx
    jmp save_to_x_num

call_print_multi:
    call print_multi

convert_to_hex:
    push ebp
    mov ebp, esp
    mov al, byte[esi] ; load the lower byte
    mov bl, byte[esi+1] ; load the higher byte

    ; Convert the first character (AL)
    ; Check if AL is a number (ASCII 0-9)
    cmp al, '0'
    jl not_a_digit
    cmp al, '9'
    jg not_a_digit
    sub al, '0'
    jmp convert_second

not_a_digit:
    ; Check if AL is a letter (ASCII A-F or a-f)
    cmp al, 'A'
    jl not_alpha
    cmp al, 'F'
    jbe is_uppercase
    cmp al, 'a'
    jl not_alpha
    cmp al, 'f'
    jg not_alpha
    sub al, 'a' - 10
    jmp convert_second

is_uppercase:
    sub al, 'A' - 10
    jmp convert_second

not_alpha:
    ; Handle invalid character
    ; You can add error handling here if needed
    jmp end_convert

convert_second:
    ; Convert the second character (BL)
    ; Check if BL is a number (ASCII 0-9)
    cmp bl, '0'
    jl not_a_digit_second
    cmp bl, '9'
    jg not_a_digit_second
    sub bl, '0'
    jmp combine_digits

not_a_digit_second:
    ; Check if BL is a letter (ASCII A-F or a-f)
    cmp bl, 'A'
    jl not_alpha_second
    cmp bl, 'F'
    jbe is_uppercase_second
    cmp bl, 'a'
    jl not_alpha_second
    cmp bl, 'f'
    jg not_alpha_second
    sub bl, 'a' - 10
    jmp combine_digits

is_uppercase_second:
    sub bl, 'A' - 10
    jmp combine_digits

not_alpha_second:
    ; Handle invalid character
    ; You can add error handling here if needed
    jmp end_convert

combine_digits:
    shl al, 4
    or al, bl
    mov [x_num + ecx], al
    inc ecx
    mov esp, ebp
    pop ebp
    ret

end_convert:
    ret

end_of_print:
    push new_line
    call printf
    add esp, 4
    mov esp, ebp ;the last used function "fix" the stack
    pop ebp ;this is the last function that is called, so it pops ebp
    ret

