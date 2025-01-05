section .data
    fmt db "argc: %d", 10, 0
    new_line db 10, 0

section .bss

section .text
    extern printf, puts
    global _start

_start:
    mov ebx, [esp]       ; Get argc
    lea ecx, [esp + 4]   ; Get argv pointer
    call main

main:
    dec ebx
    push ebx             ; Save argc
    push ecx             ; Save argv
    push ebx             ; Push argc for printf
    push fmt             ; Push format string for printf
    call printf
    add esp, 8           ; Clean up stack (2 pushes)
    pop ecx              ; Restore argv
    pop ebx              ; Restore argc
    mov esi, 1           ; Start with the first argument
    add ebx, 1
    jmp loop_argv        ; Changed from call to jmp

loop_argv:
    cmp esi, ebx         ; Compare index with argc
    jge exit             ; If index >= argc, exit
    push ecx             ; Save argv pointer
    mov eax, [ecx + esi * 4] ; Get argv[esi]
    push eax
    call puts
    add esp, 4           ; Clean up puts argument
    pop ecx              ; Restore argv pointer
    inc esi              ; Move to next argument
    jmp loop_argv

exit:
    mov eax, 1           ; sys_exit
    xor ebx, ebx         ; return 0
    int 0x80