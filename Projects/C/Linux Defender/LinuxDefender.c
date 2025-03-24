#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include <openssl/sha.h>

// Function to compute SHA256 hash of a file
void compute_sha256_hash(const char *filename, unsigned char *hash) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("Error opening file");
        return;
    }

    SHA256_CTX sha256;
    SHA256_Init(&sha256);

    const int bufSize = 32768;
    unsigned char *buffer = malloc(bufSize);
    int bytesRead = 0;

    if (!buffer) {
        fclose(file);
        return;
    }

    while ((bytesRead = fread(buffer, 1, bufSize, file))) {
        SHA256_Update(&sha256, buffer, bytesRead);
    }

    SHA256_Final(hash, &sha256);

    fclose(file);
    free(buffer);
}

// Updated scan_file function to use SHA256 hashes
int scan_file(const char *filename, char **signatures, size_t signature_count) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    compute_sha256_hash(filename, hash);

    char hash_string[SHA256_DIGEST_LENGTH * 2 + 1];
    for (int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        sprintf(hash_string + (i * 2), "%02x", hash[i]);
    }

    for (size_t i = 0; i < signature_count; i++) {
        if (strcmp(hash_string, signatures[i]) == 0) {
            return 1; // Malware found
        }
    }

    return 0; // No malware found
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file_to_scan>\n", argv[0]);
        return 1;
    }

    const char *malware_db_url = "https://bazaar.abuse.ch/browse/";
    fetch_malware_signatures(malware_db_url);

    size_t signature_count;
    char **signatures = load_malware_signatures(&signature_count);

    if (scan_file(argv[1], signatures, signature_count)) {
        printf("Malware detected in file %s!\n", argv[1]);
    } else {
        printf("No malware detected in file %s.\n", argv[1]);
    }

    // Clean up
    for (size_t i = 0; i < signature_count; i++) {
        free(signatures[i]);
    }
    free(signatures);

    return 0;
}
