.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
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
    li s2, 0
    lw s3, 0(s0)
    li t0, 0

loop_start:
    bge t0, s1, loop_end
    slli t1, t0, 2
    add t2, s0, t1
    lw t3, 0(t2)
    ble t3, s3, loop_continue
    mv s2, t0
    mv s3, t3
loop_continue:
    addi t0, t0, 1
    j loop_start
loop_end:
	# Epilogue
    mv a0, s2
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
	ret
exit_with_code_36:
    li a0, 36
    j exit
