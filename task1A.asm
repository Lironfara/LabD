extern print_multi
; 0xaa, 1,2,0x44,0x4f
; aa12444f -> 4f 44 12 aa

section .bss
    x_num resb 600
    x_struct resw 1
    
section .data
    hexa_format db "%02hx", 0  ; Format string for printf
    input_prompt db "Enter a hexadecimal number: ", 0
    new_line db 10, 0           ; Newline character
    numberFormat: db "%d", 10, 0

section .text
    global main
    extern printf, fgets, stdin, stdio


main:
    ; Call print_multi to print initial values - task1A
    lea eax, [x_struct]
    push eax ; we need to pass the address of x_struct
    call print_multi
    add esp, 4

    ; Call getmulti to get user input - task1B
    lea eax, [x_struct] ;in bsp+8
    push eax
    call getmulti
    add esp, 4
    ret


print_multi:
    push ebp
    mov ebp, esp
    push esi ;beause we use it
    push edi ;beause we use it
    push ecx ;beause we use it

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
    lea eax, [x_num]
    push dword [stdin]
    push 600
    push eax
    call fgets ;read the input of size maximum 600 into eax
    add esp, 12 

    ;process input
    mov ecx, 0 ;counter
    lea edi, [x_num] ;holds the adress of x_num
    jmp caculate_length

caculate_length: 
    cmp byte[edi + ecx], 10 ;check if the byte is 10
    je end_of_loop_input ;before the call, we jumped if it was equal to 10, now we go to end of loop input regardless?
    inc ecx
    jmp caculate_length 

end_of_loop_input:
    dec ecx ;ecx holds the length of the input
    call print_input_user


print_input_user: ;eax holds 2 chars to be printed
    cmp ecx, -1
    je end_of_print
    movzx eax, byte[edi + ecx]
    push ecx
    push eax
    push hexa_format
    call printf
    add esp, 8
    pop ecx ; restore ecx
    dec ecx
    jmp print_input_user

end_of_print:
    push new_line
    call printf
    add esp, 4
    mov esp, ebp ;the last used function "fix" the stack
    pop ebp ;this is the last function that is called, so it pops ebp
    ret

