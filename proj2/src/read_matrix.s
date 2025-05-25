.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
	## Prologue: save registers
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    # Save arguments
    mv s0, a0   # filename
    mv s1, a1   # rows pointer
    mv s2, a2   # cols pointer

    # Step 1: Open the file
    mv a0, s0
    li a1, 0    # read-only mode
    jal fopen
    li t0, -1
    beq a0, t0, error_fopen
    mv s3, a0   # save file descriptor

    # Step 2: Read rows (4 bytes)
    mv a0, s3
    mv a1, s1   # read into rows pointer
    li a2, 4
    jal fread
    li t0, 4
    bne a0, t0, error_fread_rows

    # Step 3: Read cols (4 bytes)
    mv a0, s3
    mv a1, s2   # read into cols pointer
    li a2, 4
    jal fread
    li t0, 4
    bne a0, t0, error_fread_cols

    # Step 4: Calculate elements and bytes count
    lw s5, 0(s1)   # rows
    lw s6, 0(s2)   # cols
    mul s5, s5, s6 # elements count
    slli s6, s5, 2 # bytes count (elements * 4)

    # Step 5: Allocate memory
    mv a0, s6
    jal malloc
    beqz a0, error_malloc
    mv s4, a0   # save matrix pointer

    # Step 6: Read matrix data
    mv a0, s3
    mv a1, s4
    mv a2, s6   # bytes to read
    jal fread
    bne a0, s6, error_fread_matrix

    # Step 7: Close the file
    mv a0, s3
    jal fclose
    bnez a0, error_fclose

    # Success: return matrix pointer
    mv a0, s4
    j exit_clean

error_fopen:
    li a0, 27
    j exit_clean

error_fread_rows:
    mv a0, s3
    jal fclose
    beqz a0, return_29
    li a0, 28
    j exit_clean

return_29:
    li a0, 29
    j exit_clean

error_fread_cols:
    mv a0, s3
    jal fclose
    beqz a0, return_29_cols
    li a0, 28
    j exit_clean

return_29_cols:
    li a0, 29
    j exit_clean

error_malloc:
    mv a0, s3
    jal fclose
    beqz a0, return_26
    li a0, 28
    j exit_clean

return_26:
    li a0, 26
    j exit_clean

error_fread_matrix:
    mv a0, s3
    jal fclose
    beqz a0, return_29_matrix
    li a0, 28
    j exit_clean

return_29_matrix:
    li a0, 29
    j exit_clean

error_fclose:
    li a0, 28
    j exit_clean

exit_clean:
    # Epilogue: restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    jr ra