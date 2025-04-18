.section .data
    n = 92
    buf: .space 24

.section .text
    .global _start

_start:
    bl generate_fibonacci
    bl convert_fibonacci
    bl reverse_string
    bl print_fibonacci
    b exit_success

generate_fibonacci:
    mov x3, #1
    mov x0, #0
    mov x1, #1
generate_fibonacci_loop:
    cmp x3, n
    beq generate_fibonacci_done
    add x2, x0, x1
    mov x0, x1
    mov x1, x2
    add x3, x3, #1
    b generate_fibonacci_loop
generate_fibonacci_done:
    ret

// x6 contains length of string
convert_fibonacci:
    mov x5, #10
    mov x6, #0 // Calculate length while converting to string
    ldr x4, =buf
convert_fibonacci_loop:
    sdiv x0, x1, x5
    mul x2, x0, x5
    sub x3, x1, x2
    add x3, x3, #'0'
    strb w3, [x4]
    add x4, x4, #1
    add x6, x6, #1
    mov x1, x0
    cmp x1, #0
    bne convert_fibonacci_loop
convert_fibonacci_done:
    // Add new line and null terminator to string
    mov x3, 10 // Newline
    strb w3, [x4]
    add x4, x4, #1
    add x6, x6, #1
    mov x3, 0 // Null terminator
    strb w3, [x4]
    ret

// REVERSE STRING IN BUF
reverse_string:
    ldr x0, =buf
    mov x3, #0  
    mov x4, x6 // Set x4 to length of string (x6)
    sub x4, x4, #2
    cmp x4, #3
    bne reverse_string_loop
reverse_string_loop:
    cmp x3, x4
    bge reverse_string_done
    ldrb w5, [x0, x3]
    ldrb w7, [x0, x4]
    strb w7, [x0, x3]
    strb w5, [x0, x4]
    sub x4, x4, #1
    add x3, x3, #1
    b reverse_string_loop
reverse_string_done:
    ret

print_fibonacci:
    mov x0, 1
    ldr x1, =buf
    mov x2, x6
    mov x8, 64
    svc 0
    b print_fibonacci_done
print_fibonacci_done:
    ret

exit_success:
    mov x0, #0
    mov x8, 93
    svc 0

exit_failure:
    mov x0, #1
    mov x8, 93
    svc 0
