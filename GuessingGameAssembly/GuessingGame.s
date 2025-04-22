.section .data
    seed:   .word 0
    answer: .word 0
    guess:  .word 0
    guess_num_buf:  .space 16
    input_buf:  .space 16
    result_buf: .space 16
 
    start_msg:  .asciz "Guess a number 1-10. You have 5 tries. Enter 0 to exit.\n"
    start_msg_len   = .-start_msg
    guess_msg:  .asciz "Guess #"
    guess_msg_len   = .-guess_msg
    loss_msg:   .asciz "You lost. The number was: "
    loss_msg_len    = .-loss_msg
    win_msg:    .asciz "You won!\n"
    win_msg_len     = .-win_msg


.section .text
    .global _start

_start:
    mrs     x0, CNTVCT_EL0      // Set generic timer as initial seed
    ldr     x1, =seed
    str     x0, [x1]    
    b       main_loop

main_loop:    
    bl      print_start_msg     
    bl      random_num_gen
    mov     x11, #1     // Stores number of guesses
guessing_loop:
    bl      print_guess_msg
    bl      get_input
    bl      convert_str_to_int
    ldr     x0, =guess
    ldr     w3, [x0]
    ldr     x1, =answer
    ldr     w1, [x1]
    cmp     w3, #10     // Input was greater than 10
    bgt     guessing_loop
    cmp     w3, #0      // Input was less than 0
    blt     guessing_loop
    cmp     w3, #0      // Input was 0
    beq     exit_success
    cmp     w3, w1      // Input was right answer
    beq     win
    cmp     x11, #5     // 5 incorrect guesses
    beq     lose

    add     x11, x11, #1
    b       guessing_loop

// Generate a psuedo random number
random_num_gen:
    // Load and update seed
    ldr     x0, =seed
    ldr     w1, [x0]             // w1 = old_seed
    // Constants used in div/mul
    movz    w2, #0x4E6D
    movk    w2, #0x41C6, lsl #16
    mov     w3, #12345
    mov     w4, #1023
    mov     w5, #10     
    mul     w1, w1, w2      // w1 = old_seed * A
    add     w1, w1, w3      // w1 = w1 + C
    str     w1, [x0]        // Update seed value

    // Extract high bits and mask for 10‑range
    lsr     w0, w1, #16          // take bits 16..31
    and     w0, w0, #0x03FF      // w0 = w0 & 0x3FF  (0..1023)
    udiv    w2, w0, w5
    mul     w1, w2, w5
    sub     w0, w0, w1           // w0 = w0 % 10 + 1
    add     w0, w0, #1
    ldr     x1, =answer          // Store psuedo rand num 1-10 in answer
    str     w0, [x1]
    ret


get_input:
    mov     x0, 0
    ldr     x1, =input_buf
    mov     x2, 16
    mov     x8, 63
    svc     0
    ret

// Converts a string into an integer.
convert_str_to_int:
    mov     x0, #10
    mov     x6, #0
    ldr     x5, =input_buf
convert_str_to_int_loop:
    ldrb    w2, [x5]
    cmp     w2, 10
    beq     convert_str_to_int_done
    cmp     w2, 0
    beq     convert_str_to_int_done
    cmp     w2, #'9'
    bgt     exit_failure
    cmp     w2, #'0'
    blt     exit_failure
    add     x5, x5, #1
    sub     w1, w2, #'0'
    mul     x6, x6, x0
    add     x6, x6, x1
    b       convert_str_to_int_loop

convert_str_to_int_done:
    ldr     x1, =guess
    str     x6, [x1]
    ret

print_start_msg:
    mov     x0, 1
    ldr     x1, =start_msg
    mov     x2, start_msg_len
    mov     x8, 64
    svc     0
    ret

print_guess_msg:
    mov     x0, 1
    ldr     x1, =guess_msg
    mov     x2, guess_msg_len
    mov     x8, 64
    svc     0

    ldr     x2, =guess_num_buf
    add     w1, w11, #'0'
    strb    w1, [x2]
    add     x2, x2, #1
    mov     w1, '\n'
    strb    w1, [x2]

    mov     x0, 1
    ldr     x1, =guess_num_buf
    mov     x2, 16
    mov     x8, 64
    svc     0
    ret

win:
    bl      print_win_msg
    b       main_loop

lose:
    bl      print_loss_msg
    bl      print_result
    b       main_loop

print_result:
    mov     x19, x30
    bl      convert_to_str
    mov     x0, 1
    ldr     x1, =result_buf
    mov     x2, 16
    mov     x8, 64
    svc     0
    mov     x30, x19
    ret

// Converts the result into a string 
convert_to_str:
    mov     w0, #10
    mov     x1, #0          // Length of result string
    ldr     x4, =answer
    ldr     w4, [x4]
    ldr     x2, =result_buf
convert_to_str_loop:
    sdiv    w3, w4, w0
    mul     w5, w3, w0
    sub     w5, w4, w5
    add     w5, w5, '0'
    strb    w5, [x2]
    add     x2, x2, #1
    add     x1, x1, #1
    mov     w4, w3
    cmp     w4, #0
    bne     convert_to_str_loop

reverse_str:
    // x0 is start, x1 is end of str
    mov     x0, #0
    mov     x3, x1          // Save length in x3 for later use
    ldr     x2, =result_buf
    sub     x1, x1, #1
    cmp     x3, #1
    bne     reverse_str_loop
    b       reverse_str_done

reverse_str_loop:
    cmp     x0, x1
    bge     reverse_str_done
    ldrb    w4, [x2, x0]
    ldrb    w5, [x2, x1]
    strb    w5, [x2, x0]
    strb    w4, [x2, x1]
    sub     x1, x1, #1
    add     x0, x0, #1
    b       reverse_str_loop

reverse_str_done:
    // Add null terminator to string
    mov     x0, 0           // Null terminator
    strb    w0, [x2, x3]
    add     x3, x3, #1
    mov     x0, '\n'
    strb    w0, [x2, x3]
    ret

print_win_msg:
    mov     x0, 1
    ldr     x1, =win_msg
    mov     x2, win_msg_len
    mov     x8, 64
    svc     0
    ret

print_loss_msg:
    mov     x0, 1
    ldr     x1, =loss_msg
    mov     x2, loss_msg_len
    mov     x8, 64
    svc     0
    ret
    
// Exit routines
exit_success:
    mov     x0, #0
    mov     x8, 93
    svc     0
exit_failure:
    mov     x0, #1
    mov     x8, 93
    svc     0
