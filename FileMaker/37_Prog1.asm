format PE GUI 4.0                               ;        Формат файла
entry start                                     ;        Точка с которой начинается исполнение кода
include 'WIN32A.inc'                  ;        Путь к файлу win32a.inc
                                                ;        в нем определены многие параметры и макросы

section '.data' data readable writable          ; Секции данных

        SzFile  db 'D:\Прога\Assembler\Projects\FileMaker\file.txt',0              ; Полное имя файла включая путь, строка должна заканчиваться нулем
        buffer  db 'Hello World',0              ; Буфер содержащий текст
        len_buf = $ - buffer                    ; Размер буфера
        hfile   dd ?                            ; DWORD число для сохранения хендла файла

section '.code' code readable executable        ; Секция кода

  start:                                        ; Метка с которой начнается выполнение
        invoke  _lcreat, SzFile, 0              ; Создаем файл
        mov     [hfile], eax                    ; Сохраняем хендл
        invoke  _lwrite, eax, buffer, len_buf   ; Записываем данные
        invoke  CloseHandle, [hfile]            ; Закрываем файл

  close:                                        ; Метка
        invoke  ExitProcess, 0                  ; Выходим из программы

section '.idata' import data readable writeable ; Секция импорта

  library kernel,'KERNEL32.DLL'                 ; Импортируем функции только из одной библиотеки - KERNEL32.DLL

  import kernel,\
         _lcreat,'_lcreat',\                    ; _lcreat       - Функция для создания файла
         _lwrite,'_lwrite',\                    ; _lwrite       - Функция для записи в файл
         CloseHandle,'CloseHandle',\            ; CloseHandle   - Функция для закрытия дескрипторов
         ExitProcess,'ExitProcess'              ; ExitProcess   - Завершение приложения
