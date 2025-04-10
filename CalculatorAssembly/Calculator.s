.section .data
    // Runtime constants
    buf: .space 16 // Buffer where ascii value of sum will be stored


.section .text
    .global _start

_start:
    ldr x1, [sp] // Load argc into x1
    cmp x1, #2 // Need 2 arguements: program name and input expression
    bne exit_failure

    add x1, sp, #16 // Get pointer to argv[1] on the stack
    ldr x0, [x1] // x0 contains the pointer to the string
    
    bl calc_len // x1 contains length on input string
    bl parse_input // x3 contains operator, x4 contains first number, x5 contains second number

    // Do selected operator
    cmp w3, #'+'
    beq do_add
    cmp w3, #'-'
    beq do_sub
    cmp w3, #'*'
    beq do_mul
    cmp w3, #'/'
    beq do_div

    // Operator not recognized 
    b exit_failure

// DO THE SELECTED MATHMATICAL OPERATION
do_add:
    add x4, x4, x5
    b convert_result

do_sub:
    sub x4, x4, x5
    b convert_result

do_mul:
    mul x4, x4, x5
    b convert_result

do_div:
    sdiv x4, x4, x5
    b convert_result

// EXIT WITH FAILTURE
exit_failure:
    mov x0, #1
    mov x8, 93
    svc 0

// PARSE THE INPUTED EXPRESSION
// START: x0 = pointer to the input string (argv[1]), x1 contains the length of the string
// RETURNS: x4 = first number, x3 = operator (as ASCII char), x5 = second number.
// The input must be in the format "num1opnum2", e.g., "1+1" or "12*34"
parse_input:
    mov x2, #0 // Current index
    mov x4, #0 // x4 is first number
    mov x5, #0 // x5 is the second number
parse_input_loop1:
    cmp x2, x1 // If current index is equal to length, no operator found
    bge exit_failure
    ldrb w6, [x0, x2] // xLoad x2(th) byte of input string into x6
    cmp x6, #'0' // ASCII val < 0, assume its an operator
    blt parse_operator
    cmp x6, #'9' // 0 <= ASCII val <= 9
    ble parse_digit1
    b exit_failure // ASCII value > 9, invalid character
parse_digit1:
    sub w6, w6, #'0' // Converts ASCII to number
    mov x7, #10 // Store 10 in x7
    mul x4, x4, x7 // x4 = x4 * 10
    add x4, x4, x6 // x4 = x4 + x6 (next digit)
    add x2, x2, #1 // Increment
    b parse_input_loop1
parse_operator:
    ldrb w3, [x0, x2] // Get operator, w3 is not acceptable operator handled later
    add x2, x2, #1 // Increment
parse_input_loop2:
    cmp x2, x1 // If current index is equal to length, ret
    bge parse_input_done
    ldrb w6, [x0, x2] // Load x2(th) byte of input string into x6
    cmp x6, #'0' // ASCII val < 0, error
    blt exit_failure
    cmp x6, #'9' // 0 <= ASCII val <= 9
    ble parse_digit2
    b exit_failure // ASCII value > 9, invalid character
parse_digit2:
    sub w6, w6, #'0' // Converts ASCII to number
    mov x7, #10 // Store 10 in x7
    mul x5, x5, x7 // x4 = x4 * 10
    add x5, x5, x6 // x4 = x4 + x6 (next digit)
    add x2, x2, #1 // Increment
    b parse_input_loop2
parse_input_done:
    ret

// CONVERT RESULT INTO STRING AND PRINT IT TO CONSOLE
convert_result:
    ldr x2, =buf // Load buffer into x2
    bl store_ascii_digits // Stores the result (in x4) into buf

    // Add newline and null terminator into string
    mov w4, 10 // New line character
    strb w4, [x2] // Store new line
    add x2, x2, #1 // Point to next byte
    mov w4, 0 // Null terminator
    strb w4, [x2] // Store null terminator

    ldr x0, =buf // Load buff into x0
    bl calc_len // Calculates the length of the string in the buffer (length in x1)

    bl reverse_string // Reverse the string in buf

    b print_result // Print final result

// STORE DIGITS OF RESULT INTO BUF AS CHARS
store_ascii_digits:
    mov x5, #10 // Divisor used to get individual digits
    cmp x4, #0 // Enter loop if x4 is not 0
    bne store_digit_loop
    
    // x4 is 0, store 0 to buf
    mov w3, #48 
    strb w3, [x2]
    add x2, x2, 1
    b store_digit_done
store_digit_loop:
    sdiv x3, x4, x5 // x3 = x4 / 10
    mul x6, x3, x5 // x6 = x3 * 10
    sub x7, x4, x6 // x7 (remainder) = x4 - x6
    add x7, x7, #48 // Convert remainder to ascii

    strb w7, [x2] // Store digit in w3 to x2
    add x2, x2, 1 // Increment pointer to next byte in buf

    mov x4, x3 // Move x3 (quotient) into x4 for next iteration
    cmp x4, #0 // If x4 is not 0, loop again
    bne store_digit_loop
store_digit_done:
    ret

// CALCULATE LENGTH OF BUF
calc_len:
    mov x1, #0
calc_len_loop:
    ldrb w4, [x0, x1] // Load (x1)th byte into w4
    cbz w4, calc_len_done // If w4 is null terminator, ret
    add x1, x1, #1 // Increment x1
    b calc_len_loop
calc_len_done:
    ret

// REVERSE STRING IN BUF
reverse_string:
    mov x3, #0 // Start of string
    mov x4, x1 // Set x4 to length of string (x1)
    sub x4, x4, #2 // Subtract 2 from x4 (don't reverse newline and null terminator)
    cmp x1, #3 // If length is not 1, enter the loop
    bne reverse_string_loop
reverse_string_loop:
    cmp x3, x4 // If x3 (start) >= x4, ret
    bge reverse_string_done

    ldrb w5, [x0, x3] // Load forward byte
    ldrb w6, [x0, x4] // Load backward byte
    b swap // Swap w5 and w6 in the buf
    sub x4, x4, #1 // decrement end by 1
    add x3, x3, #1 // increment start by 1
    b reverse_string_loop // loop again
swap:
    strb w6, [x0, x3] // Store w6 into x3
    strb w5, [x0, x4] // Store w5 into x4
reverse_string_done:
    ret

print_result:
    mov x2, x1 // Move length into x2
    mov x0, 1 // File descriptor for stdout
    ldr x1, =buf // load buf into x1
    mov x8, 64 // 64 is write syscall
    svc 0 // Make syscall

    // Exit 0 (success)
    mov x0, 0
    mov x8, 93
    svc 0
