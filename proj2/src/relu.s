.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
	# Prologue
    li t0, 1
    blt a1, t0, exit_with_code_36
    
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    
    mv s0, a0
    mv s1, a1
    li t0, 0
loop_start:
    beq t0, s1, loop_end
    slli s2, t0, 2
    add t1, s0, s2
    lw s3, 0(t1)
    blt x0, s3, loop_continue
    sw x0, 0(t1)
loop_continue:
    addi t0, t0, 1
    j loop_start

loop_end:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
	ret
exit_with_code_36:
    li a0, 36                  
    j exit                    