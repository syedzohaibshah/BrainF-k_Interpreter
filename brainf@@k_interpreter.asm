section .data
    ; Brainfuck program: Outputs "HELLO"
    bf_program db "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.", 0
    cells times 30000 db 0
    stack times 1000 dd 0           ; Stack for loops (like 0x80-0x8F)

section .text
    global _start

_start:
    ; Initialize
    mov esi, bf_program  ; Instruction pointer (like B)
    mov edi, cells       ; Data pointer (like C)
    mov ebx, stack       ; Stack pointer (like D)
    xor ecx, ecx         ; Instruction index

main_loop:
    mov al, [esi]        ; Load current instruction
    test al, al          ; End of program?
    je exit

    cmp al, 0x2B         ; +
    je incr
    cmp al, 0x2D         ; -
    je decr
    cmp al, 0x3E         ; >
    je next
    cmp al, 0x3C         ; <
    je prev
    cmp al, 0x2E         ; .
    je print
    cmp al, 0x5B         ; [
    je open_loop
    cmp al, 0x5D         ; ]
    je close_loop

next_instruction:
    inc esi
    jmp main_loop

incr:
    inc byte [edi]       ; Cell++
    jmp next_instruction

decr:
    dec byte [edi]       ; Cell--
    jmp next_instruction

next:
    inc edi              ; Data ptr++
    jmp next_instruction

prev:
    dec edi              ; Data ptr--
    jmp next_instruction

print:
    ; Output cell to stdout
    mov eax, 4           ; sys_write
    mov ebx, 1           ; stdout
    mov ecx, edi         ; Address of current cell
    mov edx, 1           ; Length
    int 0x80
    jmp next_instruction

open_loop:
    mov al, [edi]        ; Check cell value
    test al, al		;Tests if al is 0, setting the zero flag (ZF) if true
    jne open_loop_end	;jumps to open_loop_end if ZF is not set (i.e., [edi] ≠ 0), meaning the loop should execute.
    ; Find matching ]
    mov ecx, 1           ; Nesting level
find_close:
    inc esi
    mov al, [esi]
    test al, al
    je exit              ; Safety: end if no match
    cmp al, 0x5B         ; Nested [
    je inc_nest
    cmp al, 0x5D         ; ]
    je dec_nest
    jmp find_close
inc_nest:
    inc ecx
    jmp find_close
dec_nest:
    dec ecx
    jnz find_close
    jmp next_instruction
open_loop_end:
    mov [ebx], esi       ; Push instruction pointer
    add ebx, 4           ; Increment stack pointer
    jmp next_instruction

close_loop:
    mov al, [edi]        ; Check cell value
    test al, al
    je close_loop_end
    mov esi, [ebx-4]     ; Jump to matching [
    jmp next_instruction
close_loop_end:
    sub ebx, 4           ; Pop stack
    jmp next_instruction

exit:
    mov eax, 1           ; sys_exit
    mov ebx, 0           ; Exit code 0
    int 0x80


