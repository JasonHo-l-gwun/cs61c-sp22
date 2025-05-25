.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Prologue: Save registers and parameters
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)

    # Save arguments to saved registers
    mv s2, a0   # A pointer
    mv s3, a1   # A rows (n)
    mv s4, a2   # A cols (m)
    mv s5, a3   # B pointer
    mv s6, a4   # B rows (m)
    mv s7, a5   # B cols (k)
    mv s8, a6   # C pointer

    # Check if dimensions are valid
    li t0, 1
    blt s3, t0, error
    blt s4, t0, error
    blt s6, t0, error
    blt s7, t0, error
    bne s4, s6, error  # Check A cols == B rows

    # Initialize outer loop counter (i)
    li s0, 0

outer_loop:
    bge s0, s3, outer_end  # Loop until i >= n
    li s1, 0                # Initialize inner loop counter (j)

inner_loop:
    bge s1, s7, inner_end   # Loop until j >= k

    # Calculate A[i] pointer (row i of A)
    mul t0, s0, s4          # i * m
    slli t0, t0, 2          # Convert to bytes
    add t1, s2, t0          # t1 = A + i*m*4

    # Calculate B[j] pointer (column j of B)
    slli t2, s1, 2          # j * 4
    add t2, s5, t2          # t2 = B + j*4

    # Prepare arguments for dot product
    mv a0, t1               # A's row
    mv a1, t2               # B's column
    mv a2, s4               # Length m
    li a3, 1                # Stride for A
    mv a4, s7               # Stride for B (k)

    jal ra, dot             # Call dot product

    # Calculate C[i][j] address and store result
    mul t3, s0, s7          # i * k
    add t3, t3, s1          # i*k + j
    slli t3, t3, 2          # Convert to bytes
    add t4, s8, t3          # C + (i*k + j)*4
    sw a0, 0(t4)

    addi s1, s1, 1          # j++
    j inner_loop

inner_end:
    addi s0, s0, 1          # i++
    j outer_loop

outer_end:
    # Epilogue: Restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    addi sp, sp, 40
    ret

error:
    li a0, 38
    j exit
