#include "transpose.h"

/* The naive transpose function as a reference. */
void transpose_naive(int n, int blocksize, int *dst, int *src) {
    for (int x = 0; x < n; x++) {
        for (int y = 0; y < n; y++) {
            dst[y + x * n] = src[x + y * n];
        }
    }
}

/* Implement cache blocking below. You should NOT assume that n is a
 * multiple of the block size. */
void transpose_blocking(int n, int blocksize, int *dst, int *src) {
    // YOUR CODE HERE
        for (int block_x = 0; block_x < n; block_x += blocksize) {
        for (int block_y = 0; block_y < n; block_y += blocksize) {
            for (int x = block_x; x < block_x + blocksize && x < n; x++) {
                for (int y = block_y; y < block_y + blocksize && y < n; y++) {
                    dst[y + x * n] = src[x + y * n];
                }
            }
        }
    }
}
