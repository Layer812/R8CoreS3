#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

int parse_cart_file(const char* file_name, uint8_t* memory, const char** lua_script, uint8_t** file_buffer, uint8_t* label_image);

int main() {
    uint8_t memory[0x8000];
    const char* lua_script = NULL;
    uint8_t* file_buffer = NULL;
    uint8_t label_image[128*128];
    
    int result = parse_cart_file("carts/Desert Drift.p8.png", memory, &lua_script, &file_buffer, label_image);
    if (result != 0) {
        printf("Failed\n");
        return 1;
    }
    
    FILE* f = fopen("extracted_p8.lua", "w");
    fprintf(f, "%s", lua_script);
    fclose(f);
    
    printf("Extracted successfully.\n");
    return 0;
}
