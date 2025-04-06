section.data:
    hello db 'Hello World!', 0Ah ; Marks start of the string, 0Ah is new line character
    len equ $-hello ; Assembler direction to save the len of the string

section.text:
    global _start

_start:
    mov rax, 0x2000004 ; Write
    mov rdi, 1 ; 1 is file descriptor to write to terminal
    mov rsi, hello ; Move address into rsi register
    mov rdx, len ; Move length into rdx register
    syscall ; Make the system call

    mov rax, 0x2000001 ; Exit
    mov rdi, 0 ; Move exit value into rdi register
    syscall ; Make the system call
    