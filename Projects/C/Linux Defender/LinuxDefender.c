#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>

#define SIGNATURE_FILE "malware_signatures.txt"

// Function to write data to a file
size_t write_data(void *ptr, size_t size, size_t nmemb, FILE *stream) {
    size_t written = fwrite(ptr, size, nmemb, stream);
    return written;
}

// Function to fetch malware signatures from the URL and save to a file
void fetch_malware_signatures(const char *url) {
    CURL *curl;
    FILE *fp;
    CURLcode res;

    curl = curl_easy_init();
    if (curl) {
        fp = fopen(SIGNATURE_FILE, "wb");
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
        res = curl_easy_perform(curl);
        curl_easy_cleanup(curl);
        fclose(fp);
    }
}

// Function to load malware signatures from the file
char **load_malware_signatures(size_t *count) {
    FILE *fp = fopen(SIGNATURE_FILE, "r");
    char **signatures = NULL;
    char line[256];
    *count = 0;

    if (fp != NULL) {
        while (fgets(line, sizeof(line), fp)) {
            signatures = realloc(signatures, (*count + 1) * sizeof(char *));
            signatures[*count] = strdup(line);
            (*count)++;
        }
        fclose(fp);
    }

    return signatures;
}

// Function to scan a file for malware signatures
int scan_file(const char *filename, char **signatures, size_t signature_count) {
    FILE *fp = fopen(filename, "rb");
    char buffer[1024];
    size_t bytes_read;

    if (fp == NULL) {
        perror("Error opening file");
        return 0;
    }

    while ((bytes_read = fread(buffer, 1, sizeof(buffer), fp)) > 0) {
        for (size_t i = 0; i < signature_count; i++) {
            if (strstr(buffer, signatures[i])) {
                fclose(fp);
                return 1; // Malware found
            }
        }
    }

    fclose(fp);
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
