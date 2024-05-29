#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ucl/ucl.h>
#include <zlib.h>

// Utility functions to read and write files
unsigned char* read_file(const char* filename, long* size) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        fprintf(stderr, "Unable to open file %s\n", filename);
        return NULL;
    }
    fseek(file, 0, SEEK_END);
    *size = ftell(file);
    fseek(file, 0, SEEK_SET);
    unsigned char* buffer = (unsigned char*)malloc(*size);
    if (!buffer) {
        fprintf(stderr, "Memory allocation error\n");
        fclose(file);
        return NULL;
    }
    fread(buffer, 1, *size, file);
    fclose(file);
    return buffer;
}

void write_file(const char* filename, unsigned char* data, long size) {
    FILE *file = fopen(filename, "wb");
    fwrite(data, 1, size, file);
    fclose(file);
}

// Benchmark UCL
void benchmark_ucl(const unsigned char* input_data, long input_size) {
    unsigned int compressed_size = input_size + input_size / 8 + 256;
    unsigned char* compressed_data = (unsigned char*)malloc(compressed_size);
    unsigned char* decompressed_data = (unsigned char*)malloc(input_size);

    clock_t start = clock();
    int result = ucl_nrv2e_99_compress(input_data, input_size, compressed_data, &compressed_size, NULL, 5, NULL, NULL);
    clock_t end = clock();
    if (result != UCL_E_OK) {
        fprintf(stderr, "UCL compression failed: %d\n", result);
        free(compressed_data);
        free(decompressed_data);
        return;
    }
    double compression_time = (double)(end - start) / CLOCKS_PER_SEC;
    
    unsigned int decompressed_size = input_size;
    start = clock();
    result = ucl_nrv2e_decompress_safe_8(compressed_data, compressed_size, decompressed_data, &decompressed_size, NULL);
    end = clock();
    if (result != UCL_E_OK) {
        fprintf(stderr, "UCL decompression failed: %d\n", result);
        free(compressed_data);
        free(decompressed_data);
        return;
    }
    double decompression_time = (double)(end - start) / CLOCKS_PER_SEC;
    
    printf("UCL -> Compression time: %.5f seconds, Decompression time: %.5f seconds\n", compression_time, decompression_time);

    // Optional
    write_file("packed_ucl.out", compressed_data, compressed_size);
    write_file("unpacked_ucl.out", decompressed_data, decompressed_size);

    free(compressed_data);
    free(decompressed_data);
}

// Benchmark zlib
void benchmark_zlib(const unsigned char* input_data, long input_size) {
    unsigned long compressed_size = compressBound(input_size);
    unsigned char* compressed_data = (unsigned char*)malloc(compressed_size);
    unsigned char* decompressed_data = (unsigned char*)malloc(input_size);

    clock_t start = clock();
    int result = compress(compressed_data, &compressed_size, input_data, input_size);
    clock_t end = clock();
    if (result != Z_OK) {
        fprintf(stderr, "zlib compression failed: %d\n", result);
        free(compressed_data);
        free(decompressed_data);
        return;
    }
    double compression_time = (double)(end - start) / CLOCKS_PER_SEC;
    
    unsigned long decompressed_size = input_size;
    start = clock();
    result = uncompress(decompressed_data, &decompressed_size, compressed_data, compressed_size);
    end = clock();
    if (result != Z_OK) {
        fprintf(stderr, "zlib decompression failed: %d\n", result);
        free(compressed_data);
        free(decompressed_data);
        return;
    }
    double decompression_time = (double)(end - start) / CLOCKS_PER_SEC;
    
    printf("zlib -> Compression time: %.5f seconds, Decompression time: %.5f seconds\n", compression_time, decompression_time);
    write_file("packed_zlib.out", compressed_data, compressed_size);
    write_file("unpacked_zlib.out", decompressed_data, decompressed_size);

    free(compressed_data);
    free(decompressed_data);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }
    
    long size;
    unsigned char* input_data = read_file(argv[1], &size);
    if (!input_data) return 1;
    
    benchmark_ucl(input_data, size);
    benchmark_zlib(input_data, size);
    
    free(input_data);
    return 0;
}
