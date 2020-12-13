#include <iostream>
#include <thread>
#include <mutex>
#include <chrono>
#include <clocale>

int numberOfSavage;
int countOfMeatLeft;
int currentIndexOfSavage;
int maxCountOfMeat;
int numberOfRepeats;

std::mutex mutex;
std::thread *savageThreads;

// Метод для заполнения горшка кусками мяса
void fillPot() {
    countOfMeatLeft = maxCountOfMeat;
    std::cout << "Повар проснулся и наполнил горшок "
              << countOfMeatLeft << " кусками мяса."
              << std::endl;
    std::cout << std::endl;
}

void eating(int indexOfThread) {
    mutex.lock(); // Открываем горшок лишь одному дикарю
    currentIndexOfSavage %= numberOfSavage; // индекс этого дикаря
    countOfMeatLeft -= 1; // Дикарь скушал один кусок

    currentIndexOfSavage += 1;
    std::cout << "Поток № " << indexOfThread << ". "
              << "Дикарь №" << currentIndexOfSavage << " "
              << "скушал один кусок.";
    if (countOfMeatLeft == 0)
        std::cout << "Не осталось мяса в горшке" << std::endl;
    else
        std::cout << "Осталось " << countOfMeatLeft << " "
                  << "мяса в горшке" << std::endl;

    // при опустошение горшка повар заполняет его
    if (countOfMeatLeft == 0) {
        auto *chiefThread = new std::thread(fillPot);
        chiefThread->join();
        delete chiefThread;
    }
    mutex.unlock(); // Закрываем наш горшок и чтобы другой дикарь смог подойти
}

//метод ограничивает кол-во выполнений программы.
void repeat() {
    while (numberOfRepeats > 0) {
        for (int i = 0; i < numberOfSavage; ++i) savageThreads[i] = std::thread(eating, i + 1);
        for (int i = 0; i < numberOfSavage; ++i) savageThreads[i].join();
        --numberOfRepeats;
    }

}

int main(int argc, char **argv) {
    setlocale(LC_ALL, "Russian");

    if (argc != 4) {
        std::cerr << "Неправильное кол-во аргументов" << std::endl;
        std::cerr << "Формат: <Кол-во Дикарей> <Кол-во Кусков Мяса> <Кол-во повторений>" << std::endl;
        return 1;
    }
    try {
        numberOfSavage = std::stoi(argv[1]);
        maxCountOfMeat = std::stoi(argv[2]);
        numberOfRepeats = std::stoi(argv[3]);
    } catch (std::invalid_argument &ex) {
        std::cerr << "НE ЧИСЛО БЫЛО ПОДАНО" << std::endl;
        return 2;
    } catch (std::out_of_range &ex) {
        std::cerr << "NOT IN RANGE  OF INT" << std::endl;
        return 3;
    }
    if (numberOfSavage <= 0 || maxCountOfMeat <= 0 || numberOfRepeats <= 0) {
        std::cout << "Все значение должно быть > 0" << std::endl;
        return 3;
    }
    countOfMeatLeft = maxCountOfMeat;
    currentIndexOfSavage = 0;
    savageThreads = new std::thread[numberOfSavage];
    auto begin = std::chrono::steady_clock::now(); // Старт отсчета времени
    repeat();
    delete[]savageThreads;
    auto spentTime = std::chrono::duration_cast<std::chrono::nanoseconds>
                             (std::chrono::steady_clock::now() - begin) / 1e6;
    std::cout << "Работа программы: " << spentTime.count() << " ms" << std::endl;
    return 0;
}
