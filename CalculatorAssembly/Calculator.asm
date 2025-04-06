section __DATA,_data:
    num1 dq 2
    num2 dq 4
    result_buffer: times 20 db 0

section __TEXT,__text:
    global _start

_start:
    mov rax, [rel num1]
    add rax, [rel num2]
    add rax, 48
    mov [rel result_buffer], al

    lea rsi, [rel num1]
    mov rax, 0x2000004
    mov rdi, 1
    mov rdx, 1
    syscall

    mov rax, 0x2000001
    mov rdi, 0
    syscall
