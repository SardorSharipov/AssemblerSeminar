format PE console

entry Start

include 'win32a.inc'
include 'output.inc'

section '.data' data readable writable

        strArraySize db 'Insert number of elements in masssive: ', 0
        strIa db 'Number at [',0
        strIb db '] = ',0
        spaceStr db ', ', 0

        AStr db 'A array: ',0
        BStr db 'B array: ',0
       ; arrayStr db ' array: ', 0
        enterStr db 10,13,0
        emptyStr db '%d',0

        counter dd ?
        j dd ? ;для 2го массива
        i dd ? ;для 1го массива
        a dd ?
        A dd 100 dup(?) ;программа вылетит при попытке ввести число больше 100
        B dd 100 dup(0)


section '.code' code readable executable

        Start:  ; вступление
                invoke printf, strArraySize

                push i
                push emptyStr
                call [scanf]

                mov ebx,A
                mov [counter],0

        ArrEnter: ;ввод массива
                push strIa
                call [printf]

                push [counter]
                push emptyStr
                call [printf]

                push strIb
                call [printf]

                push a
                push emptyStr
                call [scanf]

                mov edx, [a]
                mov [ebx], edx
                add ebx,4
                add [counter],1

                mov ecx,[counter]
                cmp ecx,[i]
                jl ArrEnter

                mov ebx,A
                invoke printf, AStr
                output

                mov ebx,A
                mov eax,B
                mov ecx,0

        ArrReformer:  ; реформатор массива
                mov edx,[ebx]

                cmp edx,0
                jg addnewindex
                jmp EndReformer

                addnewindex:
                mov [eax], ecx
                add [j],1
                add eax,4

                EndReformer:

                add ebx,4
                inc ecx

                cmp ecx,[i]
                jl ArrReformer

                mov ebx,B
                invoke printf, BStr
                mov edx,[j]
                mov [i],edx

                output

        exit:
                call [getch]
                push 0
                call [ExitProcess]

section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'











