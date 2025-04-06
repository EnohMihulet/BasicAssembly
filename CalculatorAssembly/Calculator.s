.section .data
    // Runtime constants
    num1 = 1000
    num2 = 10
    op: .asciz "+" // Operand that will be used (+,-,*,/ accepted)
    buf: .space 16 // Buffer where ascii value of sum will be stored

.section .text
    .global _start

_start:
    ldr x3, =op // Move address of op into x3
    ldrb w3, [x3] // Load the op into w3

    // Do selected operator
    cmp w3, #'+'
    beq do_add

    cmp w3, #'-'
    beq do_sub

    cmp w3, #'*'
    beq do_mul

    cmp w3, #'/'
    beq do_div

    // Selected op is not +,-,*, or /, Exit with error code 1
    mov x0, 1
    mov x8, 93
    svc 0

do_add:
    mov x4, #num1
    add x4, x4, #num2
    b convert_result

do_sub:
    mov x4, #num1
    sub x4, x4, #num2
    b convert_result

do_mul:
    mov x4, #num1
    mov x5, #num2
    mul x4, x4, x5
    b convert_result

do_div:
    mov x4, #num1
    mov x5, #num2
    sdiv x4, x4, x5
    b convert_result

convert_result:
    ldr x2, =buf
    bl store_ascii_digits

    mov w4, 10 // New line character
    strb w4, [x2] // Store new line character into buffer (after result)
    add x2, x2, 1 // Increment pointer to next byte
    mov w4, 0 // Null terminator
    strb w4, [x2]

    ldr x0, =buf
    bl calc_len // Calculates the length of the string in the buffer (x1 stores result)

    bl reverse_string

    b print_result

store_ascii_digits:
    mov x5, #10

    cmp x4, #0
    bne store_digit_loop // Enter loop if x4 is not 0
    
    // Store 0 to buf
    mov w3, #48 
    strb w3, [x2]
    add x2, x2, 1
    b store_digit_done

store_digit_loop:
    sdiv x3, x4, x5 // x3 (quotient) = x4 / 10
    mul x6, x3, x5 // x6 = x3 * 10
    sub x7, x4, x6 // x7 (remainder) = x4 - x6
    add x7, x7, #48 // Convert remainder to ascii

    strb w7, [x2] // Store digit in w3 to x2
    add x2, x2, 1 // Increment pointer to next byte in buf

    mov x4, x3
    cmp x4, #0
    bne store_digit_loop

store_digit_done:
    ret

calc_len:
    mov x1, #0

calc_len_loop:
    ldrb w4, [x0, x1]
    cbz w4, calc_len_done // Null terminator reached,
    add x1, x1, #1
    b calc_len_loop

calc_len_done:
    ret

reverse_string:
    mov x3, #0
    mov x4, x1
    sub x4, x4, #2
    cmp x1, #3
    bne reverse_string_loop

reverse_string_loop:
    cmp x3, x4
    bge reverse_string_done

    ldrb w5, [x0, x3] // Load forward byte
    ldrb w6, [x0, x4] // Load backward byte
    b swap
    sub x4, x4, #1
    add x3, x3, #1
    b reverse_string_loop

swap:
    strb w6, [x0, x3]
    strb w5, [x0, x4]

reverse_string_done:
    ret

print_result:
    mov x2, x1
    mov x0, 1
    ldr x1, =buf
    mov x8, 64
    svc 0

    mov x0, 0
    mov x8, 93
    svc 0
