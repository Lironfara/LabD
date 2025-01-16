extern print_multi
extern malloc
; 0xaa, 1,2,0x44,0x4f
; aa12444f -> 4f 44 12 aa

section .bss
    print_num resb 600
    print_struct resb 1
    input_buffer resb 600
    
section .data
    hexa_format db "%02hhx", 0  ; Format string for printf
    input_prompt db "Enter a hexadecimal number: ", 0
    new_line db 10, 0           ; Newline character
    numberFormat: db "%d", 10, 0
    charFormat: db "%c", 0
    x_struct: db 5
    x_num: db 0xaa, 1,2,0x44,0x4f
    y_struct: db 6
    y_num: db 0xaa, 1,2,3,0x44,0x4f

    
section .text
    global main
    extern printf, fgets, stdin, stdio


main:
    call reasult_array ; eax holds the reault array
    call print_multi
    ret


print_multi:
    push ebp
    mov ebp, esp
    push esi ;beause we use it
    push edi ;beause we use it
    push ecx ;beause we use it
    mov edi, print_num
    movzx ecx, word [print_struct] ; Load the length of the array
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
    je check_odd_length
    inc ecx
    jmp calculate_length

check_odd_length:
    test ecx, 1 ;check if the length is odd
    jz inc_ecx_before_save
    mov byte [esi + ecx], '0'
    inc ecx
    jmp save_to_x_struct

inc_ecx_before_save:
    inc ecx
    jmp save_to_x_struct    

save_to_x_struct:
    shr ecx, 1 ;divide by 2
    mov word [print_struct], cx ;save the length
    mov edx, 0 ;
    jmp save_to_x_num

save_to_x_num:
    cmp ecx, 0
    je  call_print_multi
    call convert_to_hex
    dec ecx
    jmp save_to_x_num

call_print_multi:
    call print_multi
    jmp done
    

convert_to_hex:
    push ebp
    mov ebp, esp
    mov al, byte[esi] ; load the lower byte
    mov bl, byte[esi+1] ; load the higher byte
    add esi, 2 ; move to the next word
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
    mov [x_num + edx], al
    add edx, 2
    mov esp, ebp
    pop ebp
    ret

end_convert:
    mov esp, ebp
    pop ebp
    ret

end_of_print:
    push new_line
    call printf
    add esp, 4
    mov esp, ebp ;the last used function "fix" the stack
    pop ebp ;this is the last function that is called, so it pops ebp
    ret



reasult_array:
    push ebp
    mov ebp, esp

    ;get lengths
    movzx ecx, byte [x_struct]  ; length of first array
    movzx edx, byte [y_struct]  ; length of second array
    
    ; Find min_len
    cmp ecx, edx
    jg ecx_bigger
    xchg ecx, edx ; ecx is the bigger one


ecx_bigger:
    
    ; Allocate memory for result (maxmin + 1 for size byte)
    push ecx
    push edx
    inc ecx            ; add 1 for size byte
    mov [print_struct] , cl ; save the length of the result array
    push ecx
    call malloc ;malloc(esi)
    add esp, 4 ;now eax holds the reault array
    pop edx ;restore edx
    pop ecx ;restore ecx

    test eax, eax      ; check if malloc succeeded
    jz malloc_failed

    mov edi, eax ; edi points to the result array
    call maxmin ; eax points to the longer array

    ;eax - pointer to the longer array
    ;ebx - pointer to the shorter array
    mov esi, 0 ;index for the result array
    add eax, 1 ;skip the size byte
    add ebx, 1 ;skip the size byte
    clc ;clear the carry flag
    

;ecx - max_len
;edx - min_len
add_loop:
    cmp esi, edx ;check if we finished the shorter array
    je copy_remaining

    ;keep adding
    mov al, byte [eax + esi] ;al holds eax[esi]
    mov bl, byte [ebx + esi] ;bl holds ebx[esi]
    add al, bl ;add the two bytes
    adc [edi + esi], al ;stroe the reault in the reault array
    inc esi
    jmp add_loop

copy_remaining:
    cmp esi, ecx ;check if we finished the longer array
    je final_carry

    ;copy the remaining of the longer array
    mov al, byte [eax + esi]
    adc al, 0 ;add the carry
    mov byte [edi + esi], al ;stroe the reault in the reault array
    inc esi
    jmp copy_remaining

final_carry:
    jc carry_exists
    mov byte [edi + esi], 0 ;if no carry, pad with 0
    jmp print_reault

carry_exists:
    mov byte [edi + esi], 1 ;if carry, pad with 1
    jmp print_reault


print_reault:
    mov [print_num], edi ;save the result array
    call print_multi
    ret



maxmin:
    push ebp    
    mov ebp, esp
    movzx eax, byte [x_struct]
    movzx ebx, byte [y_struct]
    cmp eax, ebx
    jl swap_pointers
    
    jmp done ;to fix the stack

swap_pointers: ;eax will point to the longer array
    mov eax, y_struct
    mov ebx, x_struct
    jmp done ;to fix the stack



    

malloc_failed:
    mov esp, ebp ;the last used function "fix" the stack
    pop ebp ;this is the last function that is called, so it pops ebp
    ret

done: 
    mov esp, ebp ;the last used function "fix" the stack
    pop ebp ;this is the last function that is called, so it pops ebp
    ret