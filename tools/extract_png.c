#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

int parse_cart_file(const char* file_name, uint8_t* memory, const char** lua_script, uint8_t** file_buffer, uint8_t* label_image);

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("Usage: extract_png in.p8.png out.lua\n");
        return 1;
    }
    
    uint8_t memory[0x8000];
    const char* lua_script = NULL;
    uint8_t* file_buffer = NULL;
    uint8_t label_image[128*128];
    
    int result = parse_cart_file(argv[1], memory, &lua_script, &file_buffer, label_image);
    if (result != 0) {
        printf("Failed to parse\n");
        return 1;
    }
    
    FILE* f = fopen(argv[2], "w");
    if (!f) return 1;
    fprintf(f, "%s", lua_script);
    fclose(f);
    
    free((void*)lua_script);
    if (file_buffer) free(file_buffer);
    
    printf("Extracted successfully.\n");
    return 0;
}
