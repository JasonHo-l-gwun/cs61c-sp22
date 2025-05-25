.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error1
    blt a3, t0, error2
    blt a4, t0, error2
    
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
	# Prologue
    li s0, 0
    li s1, 0
loop_start:
    bge s1, a2, loop_end

    mul t0, s1, a3
    slli t0, t0, 2
    add t0, a0, t0
    lw t1, 0(t0)
    
    mul t0, s1, a4
    slli t0, t0, 2
    add t0, a1, t0
    lw t2, 0(t0)
    
    mul t3, t2, t1
    add s0, s0, t3
    addi s1, s1, 1
    j loop_start
loop_end:
    mv a0, s0
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
	# Epilogue
	ret
error1:
    li a0, 36
    j exit
    
error2:
    li a0, 37
    j exit
    