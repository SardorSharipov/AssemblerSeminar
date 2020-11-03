format PE Console
entry start

include 'F:\Прога\Assembler\INCLUDE\WIN32A.INC'
include 'F:\Прога\Assembler\Projects\HW3\MacroHW.INC'

section '.data' data readable writable

        enterStr db 'This program calculates th(x). Enter any number x, but most specific are in interval(-pi/2 < x < pi/2)', 10, 0
        numberStr db '%lf', 0
        debugStr db '%lf', 10, 0
        iterationStr db 'Iteration %d: ', 0
        currentValuesStr db 'current term = %lf, sum = %lf', 10, 0
        resultStr db 'Result: th(%lf) = %lf', 10, 0

        x dq ?  ;вводимое число
        sqrX dq ? ; квадрат х

        term dq 1.0 ; текущий член ряда

        nextTerm dq ? ; последующий член ряда

        factorialCounter dw 4

        iterationCounter dd 1
        subpow dd 2 ; 2^2n
        subpow2 dd 1 ; 2^2n-1


        sum dq 0.0 ;сумма ряда
        berRes dq ?; число Бернулли
        one dq 1.0
        minOne dq -1.0
        two dq 2.0
        inRes dq 0.0 ; промежуточные
        inSum dq 0.0 ;              переменные
        pi dq 3.141592
        temp dq 4.0
        epsilon dq 0.0005

section '.code' code readable executable

       start:
                FINIT
                call  inputNumber
                call  mainLoop
                call  outputResult

       finish:
                push 0
                invoke getch
                call ExitProcess



        zeroF:
                fld [term]
                fstp [nextTerm]
                call outputResult
                call finish
                ret
        minPiF:
                fld [one]
                fchs
                fst [nextTerm]
                fstp [sum]
                call outputResult
                call finish
                ret
        plusPiF:
                fld [one]
                fst [nextTerm]
                fstp [sum]
                call outputResult
                call finish
                ret



        inputNumber:

                invoke printf, enterStr
                invoke scanf, numberStr, x
                fld [sum]
                fld [x]
                ; производим сравнения
                fcompp
                fstsw ax
                sahf
                jz zeroF ;если 0 то функция равен 0

                fld [pi]
                fdiv [two]
                fld [x]

                fcompp
                fstsw ax
                sahf
                jae plusPiF ;если больше pi/2 то 1
                clc

                fld [pi]
                fdiv [two]
                fchs
                fld [x]
                fcompp
                fstsw ax
                sahf
                jbe minPiF ;если меньше pi/2 то -1


                fld [x]
                fmul [x]
                fstp [sqrX]; находим х^2

                fld [term]
                fmul [x]
                fstp [term]; первый член ряда равен х

                fld [term]
                fstp [sum]; сумма тоже х

        mainLoop:
                invoke printf, iterationStr,[iterationCounter]
                PrintFloat currentValuesStr, term, sum
                Inc2 iterationCounter

                fld [subpow]
                fimul [subpow]
                fstp [subpow]; получим квадрат (2^2n)в каждой итерации

                fld [subpow]
                fstp [subpow2]; получим (2^2n-1)
                Inc2 subpow2

                fld [term]
                fmul [sqrX]
                fstp [nextTerm] ; получим 2^2n-1 в каждой итерации


                bernuolli berRes,factorialCounter, one,minOne,two,inRes, inSum,pi,temp
                fld [nextTerm]
                fmul [berRes]   ;   умножаем
                fimul [subpow]   ;          полученные
                fimul [subpow2]   ;                    члены
                fstp [nextTerm]    ;

                fld [temp]
                fadd [two]      ; это как factorial iterator только qword
                fstp [temp]

                fld [sum]
                fadd [nextTerm]  ;суммируем
                fstp [sum]

                fld [sum]
                fabs
                fmul [epsilon]  ; сравниваем с эпсилон
                fld [nextTerm]
                fcompp
                fstsw ax
                sahf
                jb outputResult

                Inc factorialCounter
                Inc factorialCounter

                CopyFloat term, nextTerm
                jmp mainLoop
        ret
        outputResult:
                invoke printf, iterationStr,[iterationCounter] ;результат программы
                PrintFloat currentValuesStr, nextTerm, sum
                PrintFloat resultStr, x, sum
                call finish
        ret

section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess',\
               GetProcessHeap, 'GetProcessHeap',\
               HeapAlloc, 'HeapAlloc'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'
