section .data
    hexa_format db "%02hhx", 0  ; Format string for printf
    input_prompt db "Enter a hexadecimal number: ", 0
    new_line db 10, 0           ; Newline character

section .bss
    x_struct resw 1
    x_num resb 600
    input_buffer resb 600 

section .text
    extern printf, fgets, stdin
    global print_multi, getmulti

print_multi:
    push ebp
    mov ebp, esp
    sub esp, 8                ; Align stack to 16 bytes
    mov eax, [ebp + 8]        ; Load the address of x_struct into eax
    movzx ecx, word [eax]     ; Load array length to ecx, zero-extending to 32 bits
    cmp ecx, 0
    je end_print_multi
    mov esi, eax              ; Load the address of x_num into esi
    add esi, 2                ; Move to the first element of x_num

    ; Calculate the address of the last element
    mov edx, ecx             ; Copy length to edx
    dec edx                  ; Subtract 1 (for 0-based indexing)
    imul edx, 2             ; Multiply by 2 (size of word)
    add esi, edx            ; esi now points to last element

loop:
    pushad
    movzx eax, word [esi]     ; Load the current word into eax
    push eax                  ; Push the word onto the stack
    push hexa_format          ; Push the format string onto the stack
    call printf               ; Call printf
    add esp, 8                ; Clean up the stack
    popad                     ; Restore registers
    sub esi, 2                ; Move to the previous word (2 bytes)
    dec ecx
    cmp ecx, 0
    jne loop 

end_print_multi:
    push new_line             ; Push the newline character onto the stack
    call printf               ; Call printf to print the newline
    add esp, 4                ; Clean up the stack
    mov esp, ebp
    pop ebp
    ret

print_get_multi:
    push input_prompt
    call printf
    add esp, 4

    ; read the input
    lea eax, [input_buffer]
    push eax
    push dword [stdin]
    call fgets
    add esp, 8

    ;process input
    lea esi, [input_buffer]
    mov cx, 0

count_words:
    movzx ax, word [esi]
    cmp ax, 0
    je end_count_words
    add cx, 1
    add esi, 2
    jmp count_words


end_count_words:
    ; now ecx holds the number of words
    movzx word [x_struct], cx  ; Store the number of words in x_struct

    ; Copy the input buffer to x_num
    lea esi, [input_buffer]  ; Load the address of input_buffer into esi
    lea edi, [x_num]         ; Load the address of x_num into edi
    movzx ecx, word [x_struct] ; Load the number of words into ecx
    shl ecx, 1               ; Multiply by 2 to get the number of bytes
    rep movsb                ; Copy ecx bytes from input_buffer to x_num
