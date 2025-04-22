.section .data
    start_msg:  .asciz "\nEnter: 1 for the sum, 2 for the maximum, 3 for the minimum, 4 for the minimum, 5 to display the array, 6 to display the index of a desired element, and 7 to sort the array. Enter 0 to exit.\nInput: "
    msg_len =   .-start_msg        

    inpt_buf:   .space 16    // Stores the input string
    buf_size =  .-inpt_buf
    input:      .xword 0      // Stores the input as a 32-bit value

    array:      .xword 4, 2, 3, 6, 1, 5, 7, 9, 8
    len =       .-array     // Stores the total size in bytes

    sum:        .xword 0                            
    max:        .xword 0                            
    min:        .xword 0
    index:      .xword 0        
    result:     .xword 0

    sum_str:         .asciz "Sum: "
    sum_str_len =    .-sum_str
    max_str:         .asciz "Max: "
    max_str_len =    .-max_str
    min_str:         .asciz "Min: "
    min_str_len =    .-min_str
    avg_str:         .asciz "Avg: "
    avg_str_len =    .-avg_str
    search_str:      .asciz "Index: "
    search_str_len = .-search_str

    search_req_str:  .asciz "Enter a number: "
    search_req_str_len = .-search_req_str
    search_fail_str: .asciz "Element not found.\n"
    search_fail_str_len = .-search_fail_str

    result_buf:      .space 16
    result_buf_size: .xword 0

    array_str_buf:   .space len
    array_str_buf_size = .-array_str_buf

    search_inpt_buf: .space 8
    search_inpt_buf_size = .-search_inpt_buf

    new_line:        .asciz "\n"
    
.section .text
    .global _start

_start:
    b main_loop

main_loop:
    bl      print_start_msg
    ldr     x1, =inpt_buf
    mov     x2, buf_size
    bl      read_input
    bl      parse_input

    ldr     x1, =input
    ldr     w0, [x1]

    cmp     x0, #0
    beq     exit_success
    cmp     x0, #1
    beq     do_sum
    cmp     x0, #2
    beq     do_max
    cmp     x0, #3
    beq     do_min
    cmp     x0, #4
    beq     do_avg
    cmp     x0, #5
    beq     print_array
    cmp     x0, #6
    beq     do_search_array
    cmp     x0, #7
    beq     do_sort_array

    b       exit_failure

// Computes the result of and prints the desired operation
// Returns to the main loop once finished
do_sum:
    bl      sum_array
    ldr     x4, =sum
    ldr     x4, [x4]
    bl      convert_to_str
    bl      print_sum
    bl      print_result
    bl      print_new_line
    b       main_loop

do_max:
    bl      find_max
    ldr     x4, =max
    ldr     x4, [x4]
    bl      convert_to_str
    bl      print_max
    bl      print_result
    bl      print_new_line
    b       main_loop

do_min:
    bl      find_min
    ldr     x4, =min
    ldr     x4, [x4]
    bl      convert_to_str
    bl      print_min
    bl      print_result
    bl      print_new_line
    b       main_loop

do_avg:
    // Sum array, convert len from bytes to # of elements, then find and print avg
    bl      sum_array
    ldr     x4, =sum
    ldr     x4, [x4]
    mov     x5, len
    mov     x6, #8
    sdiv    x5, x5, x6 
    sdiv    x4, x4, x5
    bl      convert_to_str
    bl      print_avg
    bl      print_result
    bl      print_new_line
    b       main_loop

do_search_array:
    bl      print_req_search_str
    ldr     x1, =search_inpt_buf
    mov     x2, search_inpt_buf_size
    bl      read_input
    ldr     x5, =search_inpt_buf
    bl      convert_str_to_int
    ldr     x1, =result
    str     x6, [x1]
    bl      search_array // Index not found handled here
    ldr     x4, =index
    ldr     x4, [x4]
    bl      convert_to_str
    bl      print_search
    bl      print_result
    bl      print_new_line
    b       main_loop

// Selection sort 
do_sort_array:
    mov     x0, #0 // Looping 1
    mov     x1, #0 // Looping 2
    ldr     x2, =array
    ldr     x3, [x2, x1]
    mov     x5, x1 // Index of min
selection_loop:
    cmp     x0, len
    beq     selection_loop_done
    bl      find_index_minimum
    ldr     x4, [x2, x0]
    str     x4, [x2, x5]
    str     x3, [x2, x0]
    add     x0, x0, #8
    mov     x1, x0
    ldr     x3, [x2, x1]
    mov     x5, x1
    b       insertion_loop

find_index_minimum:
    add     x1, x1, #8
    ldr     x4, [x2, x1]
    cmp     x1, len
    beq     find_index_minimum_done
    cmp     x3, x4
    blt     find_index_minimum
    mov     x3, x4
    mov     x5, x1
    b       find_index_minimum

find_index_minimum_done:
    ret

selection_loop_done:
    b       print_array

// Prints the array
print_array:
    mov     x9, #0
    ldr     x10, =array_str_buf
    mov     x12, array_str_buf_size
    ldr     x13, =array
    mov     x14, 91   // Open bracket
    strb    w14, [x10]
    add     x10, x10, #1
print_array_loop:
    ldr     x4, [x13, x9]
    bl      convert_to_str
    ldr     x11, =result_buf
    bl      add_result_to_array_loop
    mov     x14, 44   // Comma
    strb    w14, [x10]
    add     x10, x10, #1
    mov     x14, 32   // Space
    strb    w14, [x10]
    add     x10, x10, #1
    add     x9, x9, #8
    cmp     x9, len
    beq     print_array_done
    b       print_array_loop

add_result_to_array_loop:
    ldrb    w14, [x11]
    cmp     x14, 0  // Null terminator
    beq     add_result_to_array_done
    strb    w14, [x10]
    add     x10, x10, #1
    add     x11, x11, #1
    b       add_result_to_array_loop

add_result_to_array_done:
    ret

print_array_done:
    mov     x14, 93
    sub     x10, x10, #2
    strb    w14, [x10]
    add     x10, x10, #1
    mov     x14, 10 // Newline
    strb    w14, [x10]
    mov     x0, 1
    ldr     x1, =array_str_buf
    mov     x2, array_str_buf_size
    mov     x8, 64
    svc     0
    b       main_loop

// Converts the result into a string 
// Assumes result being converted is x4
convert_to_str:
    mov     x0, #10
    mov     x1, #0 // Length of result string
    ldr     x2, =result_buf
convert_to_str_loop:
    sdiv    x3, x4, x0
    mul     x5, x3, x0
    sub     x5, x4, x5
    add     x5, x5, #'0'
    strb    w5, [x2]
    add     x2, x2, #1
    add     x1, x1, #1
    mov     x4, x3
    cmp     x4, #0
    bne     convert_to_str_loop

reverse_str:
    // x0 is start, x1 is end of str
    mov     x0, 0
    mov     x3, x1 // Save length in x3 for later use
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
    mov     x0, 0 // Null terminator
    strb    w0, [x2, x3]
    ldr     x0, =result_buf_size
    str     x3, [x0]
    ret

// Converts a string into an integer.
// Assumes the pointer to string is in x5, stores result in x6
convert_str_to_int:
    mov     x0, #10
    mov     x6, #0
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
    sub     x1, x2, #'0'
    mul     x6, x6, x0
    add     x6, x6, x1
    b       convert_str_to_int_loop

convert_str_to_int_done:
    ret

// Prints the result
print_sum:
    mov     x0, 1
    ldr     x1, =sum_str
    mov     x2, sum_str_len
    mov     x8, 64 
    svc     0
    ret

print_max:
    mov     x0, 1
    ldr     x1, =max_str
    mov     x2, max_str_len
    mov     x8, 64 
    svc     0
    ret

print_min:
    mov     x0, 1
    ldr     x1, =min_str
    mov     x2, min_str_len
    mov     x8, 64 
    svc     0
    ret

print_avg:
    mov     x0, 1
    ldr     x1, =avg_str
    mov     x2, avg_str_len
    mov     x8, 64 
    svc     0
    ret

print_search:
    mov     x0, 1
    ldr     x1, =search_str
    mov     x2, search_str_len
    mov     x8, 64 
    svc     0
    ret

print_result:
    mov     x0, 1
    ldr     x1, =result_buf
    ldr     x2, =result_buf_size
    ldr     x2, [x2]
    mov     x8, 64
    svc     0
    ret

print_req_search_str:
    mov     x0, 1
    ldr     x1, =search_req_str
    mov     x2, search_req_str_len
    mov     x8, 64
    svc     0
    ret

print_search_fail:
    mov     x0, 1
    ldr     x1, =search_fail_str
    mov     x2, search_fail_str_len
    mov     x8, 64
    svc     0
    ret

// Sums up the elements of the array until sentinel is reached (-1)
sum_array:
    mov     x0, #0 // Position
    ldr     x1, =array // Pointer to array
    mov     x3, #0 // Running sum
sum_array_loop:
    ldr     x4, [x1, x0]
    cmp     x0, len
    beq     sum_array_done
    add     x3, x3, x4
    add     x0, x0, #8
    b       sum_array_loop

sum_array_done:
    ldr     x0, =sum
    str     x3, [x0]
    ret

// Finds the maximum value of the array
find_max:
    mov     x0, #0
    ldr     x1, =array
    ldr     x2, [x1, x0] // Max is set to first number
find_max_loop:
    add     x0, x0, #8 // Start at second element (max is set to first element)
    ldr     x3, [x1, x0]
    cmp     x0, len
    beq     find_max_done
    cmp     x3, x2
    bgt     update_max
    b       find_max_loop

update_max:
    mov     x2, x3
    b       find_max_loop

find_max_done:
    ldr     x0, =max
    str     x2, [x0]
    ret

// Finds the minimum value of the array
find_min:
    mov     x0, #0
    ldr     x1, =array
    ldr     x2, [x1, x0] // Min is set to first number
find_min_loop:
    add     x0, x0, #8 // Start at second element (min is set to first element)
    ldr     x3, [x1, x0]
    cmp     x0, len
    beq     find_min_done
    cmp     x3, x2
    blt     update_min
    b       find_min_loop

update_min:
    mov     x2, x3
    b       find_min_loop

find_min_done:
    ldr     x0, =min
    str     x2, [x0]
    ret

// Search the array for an element, return index
search_array:
    mov     x0, #0 // Index of element
    mov     x4, #0
    ldr     x1, =result
    ldr     x1, [x1] // Searching for x1
    ldr     x2, =array
search_array_loop:
    ldr     x3, [x2, x4]
    cmp     x1, x3
    beq     search_array_done
    cmp     x4, len
    bge     search_array_fail
    add     x4, x4, #8
    add     x0, x0, #1
    b       search_array_loop

search_array_done:
    ldr     x1, =index
    str     x0, [x1]
    ret

search_array_fail:
    bl      print_search_fail
    b       main_loop

// Prints the start_msg string
print_start_msg:
    mov     x0, 1
    ldr     x1, =start_msg
    mov     x2, msg_len
    mov     x8, 64 
    svc     0
    ret

print_new_line:
    mov     x0, 1
    ldr     x1, =new_line
    mov     x2, 1
    mov     x8, 64 
    svc     0
    ret

// Reads the input from the console
// Expects pointer to buffer and size to be in x1, and x2 respectively
read_input:
    mov     x0, 0
    mov     x8, 63
    svc     0
    ret

// Parses the input and stores integer value in variable, exits if invalid input
parse_input:
    mov     x0, #0
    ldr     x1, =inpt_buf
    ldrb    w2, [x1, x0]
    cmp     w2, #10
    beq     exit_failure
    cmp     w2, #'9'
    bgt     exit_failure
    cmp     w2, #'0'
    blt     exit_failure
    add     x0, x0, #1
    ldrb    w3, [x1, x0]
    cmp     w3, #10
    beq     parse_input_done
    b       exit_failure

parse_input_done:
    sub     w2, w2, #'0'
    ldr     x0, =input
    str     w2, [x0]
    ret

// Exit Routines
exit_success:
    mov     x0, #0
    mov     x8, 93
    svc     0

exit_failure:
    mov     x0, #1
    mov     x8, 93
    svc     0
