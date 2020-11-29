#include <iostream>
#include <vector>
#include <thread>
#include <chrono>
#include <cmath>
#include <random>
#include <omp.h>

std::string *result;

void WordToEncrypt(const std::string &word, int shiftCaesar, int i) {
    std::string en;
    for (char c : word)
        if (c != ' ')
            en += std::to_string(static_cast<int>((c - 'a' + shiftCaesar) % 26 + 'a'));
        else
            en += std::to_string(static_cast<int>(c));
    result[i] = en;
}

void ThreadToCreate(const std::string &text, int threadNumber, int shiftCaesar) {
    auto startTime = std::chrono::high_resolution_clock::now();

    // main loop
    result = new std::string[threadNumber];
    int wordLength = ceil(text.size() * 1.0 / threadNumber);

    auto *words = new std::string[threadNumber];
    int begin = 0;
    for (int j = 0; j < threadNumber; j++) {
        words[j] = text.substr(begin, wordLength);
        begin += wordLength;
    }

    omp_lock_t writeLock;
    omp_init_lock(&writeLock);

#pragma omp parallel for
    for (int j = 0; j < threadNumber; j++) {
        WordToEncrypt(words[j], shiftCaesar, j);

        omp_set_lock(&writeLock);
        std::cout << "UnEncrypted piece: " << words[j] << std::endl;
        std::cout << "Encrypted message: ";
        //for (int i = 0; i < threadNumber; i++)
        std::cout << result[j] << std::endl;

        auto stopTime = std::chrono::high_resolution_clock::now();
        auto duration = stopTime - startTime;
        std::cout << "Time spent on calculation" << threadNumber << "  => "
                  << duration.count() * 1.0 / 10000000 << std::endl << std::endl;
        omp_unset_lock(&writeLock);
    }

    omp_destroy_lock(&writeLock);
    delete[] words;
}

// argv[1] - > input message;
int main(int argc, char *argv[]) {

    std::random_device rd;
    std::mt19937 mt(rd());
    std::uniform_int_distribution<uint8_t> dist(0, 25);

    int shiftCaesar = dist(mt);
    if (argc != 2) {
        std::cout << "Input text to encrypt" << std::endl;
        return 0;
    }

    std::string message = argv[1];
    std::string text;
    std::cout << "Shift => " << shiftCaesar << std::endl;
    for (const char c: message) {
        if (c <= 'Z' && c >= 'A')
            text += std::tolower(c);
        else
            text += c;
    }
    std::cout << "Unencrypted message: " << text << std::endl;
    ThreadToCreate(text, static_cast<int>(sqrt(text.size())), shiftCaesar);
    delete[] result;
    return 0;
}
