.section .data
    msg: .asciz "Hello, World!\n" // msg string
    len = . -msg // length of msg string (difference between current position and end of msg string)

.section .text
    .global _start

_start:
    mov x0, 1 // 1 into x0 register (1 is file descriptor for stdout (terminal))
    ldr x1, =msg // msg string into x1 register
    mov x2, len // length of msg into x2 register
    mov x8, 64 // Write syscall
    svc 0 // Make syscall

    mov x0, 0 // 0 into x0 register (success)
    mov x8, 93  // Exit syscall
    svc 0 // Make syscall 
    