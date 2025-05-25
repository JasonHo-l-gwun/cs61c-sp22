.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # Prologue: Save registers and return address
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    # Save matrix pointer, rows, and columns
    mv s1, a1       # s1 = matrix pointer
    mv s2, a2       # s2 = number of rows
    mv s3, a3       # s3 = number of columns

    # Open the file (fopen)
    li a1, 1        # Write mode
    call fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s0, a0       # s0 = file descriptor

    # Write rows and columns to the file
    addi sp, sp, -8
    sw s2, 0(sp)    # Store rows on stack
    sw s3, 4(sp)    # Store columns on stack
    mv a0, s0       # File descriptor
    mv a1, sp       # Buffer address
    li a2, 2        # Number of elements (2 integers)
    li a3, 4        # Size of each element (4 bytes)
    call fwrite
    addi sp, sp, 8  # Deallocate buffer

    # Check if rows and columns were written correctly
    li t0, 2
    bne a0, t0, fwrite_error

    # Write matrix data to the file
    mul t1, s2, s3  # t1 = total elements (rows * columns)
    mv a0, s0       # File descriptor
    mv a1, s1       # Matrix pointer
    mv a2, t1       # Number of elements
    li a3, 4        # Size of each element (4 bytes)
    call fwrite

    # Check if matrix data was written correctly
    bne a0, t1, fwrite_error

    # Close the file (fclose)
    mv a0, s0
    call fclose
    li t0, 0
    bne a0, t0, fclose_error

    # Epilogue: Restore registers and return
    lw ra, 16(sp)
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 20
    ret

fopen_error:
    li a0, 27
    j exit

fwrite_error:
    li a0, 30
    j exit

fclose_error:
    li a0, 28
    j exit