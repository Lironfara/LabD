extern print_multi
extern malloc
; 0xaa, 1,2,0x44,0x4f
; aa12444f -> 4f 44 12 aa

section .bss
    print_num resb 600 ;for actual array
    print_struct resb 2 ;for length
    input_buffer resb 600
    x_num_bss resb 600  ; Add this for storing first input number
    y_num_bss resb 600  ; Add this for storing second input number
    x_struct_bss resb 2 ; Add this for storing first length
    y_struct_bss resb 2 ; Add this for storing second length
    
section .data
    hexa_format db "%02hhx", 0  ; Format string for printf
    input_prompt db "Enter a hexadecimal number: ", 0
    new_line db 10, 0           ; Newline character
    numberFormat: db "%d", 10, 0
    charFormat: db "%c", 0
    STATE db 0xE1, 0xAC  ; Initial state (0xACE1) in little-endian
    MASK  db 0x00, 0xB4  ; MASK (0xB400) in little-endian
    deafult_x_struct: db 5
    deafult_x_num: db 0xaa, 1,2,0x44,0x4f
    deafult_y_struct: db 6
    deafult_y_num: db 0xaa, 1,2,3,0x44,0x4f
    input_flag db "-I", 0
    random_flag db "-R", 0
    sum_msg db "Sum: ", 0

    
section .text
    global main
    extern printf, fgets, stdin, stdio, strcmp, time


main:
    push ebp ;this is the first function that is called, so it pushes ebp
    mov ebp, esp

    ;one command line - deafult
    mov eax, [ebp + 8] ;get the argc
    cmp eax, 1

    je deafult_program
    
    mov ebx, [ebp + 12]     ; argv
    mov ebx, [ebx + 4]      ; argv[1]

    push ebx
    push input_flag
    call strcmp
    add esp, 8
    test eax, eax
    jz input_mode
    
    ;call getmulti
    ;call reasult_array ; eax holds the reault array

    push ebx
    push random_flag
    call strcmp
    add esp, 8
    test eax, eax
    jz random_mode
    ret


deafult_program:
    ; First print x_num
    movzx eax, byte [deafult_x_struct]    ; Get length
    mov [print_struct], al                ; Set length for print_multi
    
    ; Copy x_num to print_num for printing
    xor ecx, ecx
copy_x_to_print:
    cmp ecx, eax
    jge print_first
    mov bl, byte [deafult_x_num + ecx]
    mov [print_num + ecx], bl
    inc ecx
    jmp copy_x_to_print

print_first:
    call print_multi

    ; Now copy x_num to x_num_bss for adding part
    movzx eax, byte [deafult_x_struct]
    mov [x_struct_bss], al
    
    xor ecx, ecx
setup_x:
    cmp ecx, eax
    jge setup_y_print
    mov bl, byte [deafult_x_num + ecx]
    mov [x_num_bss + ecx], bl
    inc ecx
    jmp setup_x

setup_y_print:
    ; Print y_num
    movzx eax, byte [deafult_y_struct]
    mov [print_struct], al
    
    xor ecx, ecx
copy_y_to_print:
    cmp ecx, eax
    jge print_second
    mov bl, byte [deafult_y_num + ecx]
    mov [print_num + ecx], bl
    inc ecx
    jmp copy_y_to_print

print_second:
    call print_multi

    ; Now setup y_num_bss
    movzx eax, byte [deafult_y_struct]
    mov [y_struct_bss], al
    
    xor ecx, ecx
setup_y:
    cmp ecx, eax
    jge addition_deafult
    mov bl, byte [deafult_y_num + ecx]
    mov [y_num_bss + ecx], bl
    inc ecx
    jmp setup_y

addition_deafult:
    call reasult_array
    jmp done


input_mode:
    ;get the first number from user
    call getmulti ; print_num and print_struct are filled

    call print_multi

  ; Save first number for addition
    movzx eax, byte [print_struct]
    mov [x_struct_bss], al        ; Save length
    
    ; Copy first number bytes to x_num
    xor ecx, ecx
copy_to_x:
    cmp ecx, eax
    jge get_second_num
    mov bl, byte [print_num + ecx]
    mov [x_num_bss + ecx], bl
    inc ecx
    jmp copy_to_x

get_second_num:
    ; Get second number
    call getmulti
    
    ; Print second number
    call print_multi
    
    ; Save second number for addition
    movzx eax, byte [print_struct]
    mov [y_struct_bss], al        ; Save length
    
    ; Copy second number bytes to y_num
    xor ecx, ecx

copy_to_y:
    cmp ecx, eax
    jge do_addition
    mov bl, byte [print_num + ecx]
    mov [y_num_bss + ecx], bl
    inc ecx
    jmp copy_to_y

do_addition:
    call reasult_array
    jmp done


random_mode:

    push 0
    call time
    add esp, 4

    rol eax, 13
    xor eax, 0x12345678
    mov byte [STATE], al
    mov byte [STATE + 1], ah
    ; Generate and print first number
    call PRmulti
    
    ; Save first number for addition
    movzx eax, byte [print_struct]
    mov [x_struct_bss], al        ; Save length
    
    ; Copy first number bytes
    xor ecx, ecx
copy_first:
    cmp ecx, eax
    jge generate_second
    mov bl, byte [print_num + ecx]
    mov [x_num_bss + ecx], bl
    inc ecx
    jmp copy_first

generate_second:
    ; Generate and print second number
    call PRmulti
    
    ; Save second number for addition
    movzx eax, byte [print_struct]
    mov [y_struct_bss], al        ; Save length
    
    ; Copy second number bytes
    xor ecx, ecx
copy_second:
    cmp ecx, eax
    jge do_addition_random
    mov bl, byte [print_num + ecx]
    mov [y_num_bss + ecx], bl
    inc ecx
    jmp copy_second

do_addition_random:
    call reasult_array
    jmp done


print_multi:
    push ebp
    mov ebp, esp
    push esi ;beause we use it
    push edi ;beause we use it
    push ecx ;beause we use it
    movzx ecx, byte [print_struct] ; Load the length of the array
    dec ecx 

loop:
    cmp ecx, -1               ; Check if ecx is 0
    je end_print_multi        ; If ecx is 0, jump to end_print_multi
    movzx eax, byte [print_num + ecx] ; Load the value - start at end of array
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
    lea esi, [input_buffer] ;esi holds the input buffer
    mov ecx, 0

calculate_length:
    movzx edi, byte [esi + ecx]
    cmp edi, 0xa ;for new line
    je check_odd_length
    inc ecx
    jmp calculate_length

check_odd_length:
    test ecx, 1 ;check if the length is odd
    jz inc_ecx_before_save
    mov byte [esi + ecx], '0'
    inc ecx
    jmp save_to_reault_struct

inc_ecx_before_save:
    inc ecx
    jmp save_to_reault_struct    

save_to_reault_struct:

    shr ecx, 1 ;divide by 2
    mov byte [print_struct], cl ;save the length

    mov edx, 0 ;
    jmp save_to_reault_num

save_to_reault_num:
    cmp ecx, 0
    je  call_print_multi
    lea edi, print_num
    call convert_to_hex
    dec ecx
    jmp save_to_reault_num

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
    mov [print_num + edx], al
    inc edx ;storing one byte
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
    movzx ecx, byte [x_struct_bss]  ; length of first array
    movzx edx, byte [y_struct_bss]  ; length of second array
    
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

    push eax ;save the pointer longer array
    push ebx ;save the pointer shorter array
    mov eax, [esp + 4] ;eax - pointer to the longer array
    mov ebx, [esp] ;ebx - pointer to the shorter array

    ;eax - pointer to the longer array
    ;ebx - pointer to the shorter array
    mov esi, 0 ;index for the result array
    clc ;clear the carry flag
    

;ecx - max_len
;edx - min_len
add_loop:
    pushfd ;save the flags (carry)
    cmp esi, edx ;check if we finished the shorter array
    je restore_carry
    popfd ;restore the flags (carry)

    ;keep adding
    push eax ;save the pointer to the longer array
    push ebx ;save the pointer to the shorter array

    ;use temporary registers to hold the values
    mov al, byte [eax + esi] ;al holds eax[esi]
    mov bl, byte [ebx + esi] ;bl holds ebx[esi]
    adc al, bl ;add the two bytes

    mov [edi + esi], al ;store the result BEFORE popping
    
    pop ebx ;restore the pointer to the shorter array
    pop eax ;restore the pointer to the longer array

    inc esi
    jmp add_loop


restore_carry:
    popfd ;restore the flags (carry)
    
copy_remaining:
 
    cmp esi, ecx ;check if we finished the longer array
    je final_carry

    pushfd
    ;copy the remaining of the longer array
    mov al, byte [eax + esi]
    popfd
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
    
    ;Add a loop to copy the entire array
    mov ecx, 0  ; Initialize counter
    movzx edx, byte [print_struct]

copy_result_loop:
    cmp ecx, edx       ; Compare with length
    je done_copying
    mov al, byte [edi + ecx]  ; Get byte from result
    mov byte [print_num + ecx], al  ; Store in print_num (offset by 1 for size byte)
    inc ecx
    jmp copy_result_loop

done_copying:
    call print_multi
    jmp done
    ret


maxmin:
    push ebp    
    mov ebp, esp
    movzx eax, byte [x_struct_bss]
    movzx ebx, byte [y_struct_bss]
    cmp eax, ebx
    jl swap_pointers
    
    mov eax, x_num_bss     ; Return pointer to x_num_bss
    mov ebx, y_num_bss     ; Return pointer to y_num_bss
    mov esp, ebp
    pop ebp
    ret

swap_pointers: ;eax will point to the longer array
    mov eax, y_num_bss
    mov ebx, x_num_bss
    mov esp, ebp
    pop ebp
    ret



malloc_failed:
    mov esp, ebp ;the last used function "fix" the stack
    pop ebp ;this is the last function that is called, so it pops ebp
    ret


; Purpose: Generate a random 16-bit number using LFSR algorithm
;Input: Uses two global variables:
;- STATE (2 bytes): initial value like 0xE1, 0xAC
;- MASK (2 bytes): like 0x00, 0xB4

;Process in each call:
;1. Take current STATE value
;2. AND it with MASK
;3. Count number of 1's in the result (parity)
;4. Shift STATE right by 1
;5. Set leftmost bit of STATE based on parity
;6. Save new STATE value

;Output: Returns a random number in ax (16 bits)
rand_num:
    push ebp
    mov ebp, esp

    ; Load STATE into ax
    mov al, [STATE]      
    mov ah, [STATE + 1] 
    
    rol ax, 3
    xor ax, 0x1234
    ; Copy STATE to bx for masking
    mov bx, ax
    
apply_MASK:
    mov cl, [MASK]
    mov ch, [MASK + 1]
    and bx, cx          ; bx now has masked value

    ; Count 1's for parity
    mov cx, bx          ; Copy masked value to count bits
    xor dl, dl          ; dl will count 1's
count_ones:
    test cx, cx         ; Check if all bits are counted
    jz done_counting
    mov dh, cl          
    and dh, 1           ; Check rightmost bit
    add dl, dh          ; Add to count
    shr cx, 1           ; Move to next bit
    jmp count_ones

done_counting:
    ; dl has count of 1's
    test dl, 1          ; Test if count is odd
    pushfd               ; Save result
    
    ; Shift original state right
    shr ax, 1
    
    popfd                ; Restore odd/even test result
    jz even_count       ; If even skip setting MSB
    or ah, 0x80        ; Set MSB to 1 if count was odd

even_count:

    ror ax, 7
    ; Save new state
    mov [STATE], al
    mov [STATE + 1], ah
    
    ; Return value is in ax
    mov esp, ebp
    pop ebp
    ret


;Purpose: Create a multi-precision number with random length and random bytes

;Process:
;1. Call rand_num to get a random number
;2. Use its upper byte as length (n)
;3. If length is 0, try again
;4. Call rand_num n times to generate n random bytes
;5. Store in format: [length][byte1][byte2]...[byten]

;Output: A structure ready for print_multi:
;- print_struct: contains length
;- print_num: contains the random bytes
PRmulti:
    push ebp
    mov ebp, esp
    
    ; Get random length
get_length:
    call rand_num       ; Get random number in ax
    mov al, ah         ; Take upper byte for length
    and al, 0x0F       ; Mask upper 4 bits
    test al, al        ; Check if length is 0
    jz get_length      ; If 0, try again
    
    ; Store length
    mov [print_struct], al
    
    ; Generate random bytes
    xor ecx, ecx       ; Initialize counter
    
generate_bytes:
    movzx edx, byte [print_struct] ;ebx is the number of times we need to get a random number
    cmp ecx, edx       ; Compare counter with length
    jge done_generating
    
    push ecx           ; Save counter
    call rand_num      ; Get random number
    pop ecx            ; Restore counter
    
    mov [print_num + ecx], al  ; Store random byte
    inc ecx
    jmp generate_bytes

done_generating:
    call print_multi    ; Print the random number
    mov esp, ebp
    pop ebp
    ret


done: 
    mov esp, ebp ;the last used function "fix" the stack
    pop ebp ;this is the last function that is called, so it pops ebp
    ret