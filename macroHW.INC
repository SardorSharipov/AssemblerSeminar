; Макрос для вывода чисел с плавующей запятой.
macro PrintFloat string, [args] {
 reverse
  push dword[args + 4]
  push dword[args]
 common
  push string
  call [printf]
}

; Макрос, инкрементирующий значение переменной word.
macro Inc value {
 mov cx, [value]
 inc cx
 mov [value], cx
}

; Макрос, инкрементирующий значение переменной dword.
macro Inc2 value {
 mov ecx, [value]
 inc ecx
 mov [value], ecx
}

; Макрос, копирующий значение одного числа с плавующей запятой в другое.
macro CopyFloat to, from {
 mov eax, dword[from]
 mov ebx, dword[from + 4]
 mov dword[to], eax
 mov dword[to + 4], ebx
}
; Макрос для подсчета чисел Бернулли B_2n
; B_2n  = (-1)^(n+1) * 2/(2pi)^2n * E(2n)
; E(2n) = зета функция Эйлера
; E(2k) = Sum (1/n)^2k
; зедсь в коде  n как 2n в формуле
macro bernuolli result,n, one,minOne, two, inRes, inSum , pi, temp{
  
  mov cx, [n]
  fld [two]  
  b:
    fdiv [two]      
  loop b ; 2/2^2n

 mov cx, [n]  
  c:
    fdiv [pi]      
  loop c ; 2/(2pi)^2n

 fstp [result]

 mov cx, [n]
  d:
    mov bx, cx
    
    fld [one]
    mov cx, [n]      
    e:
      fdiv [temp]   
    loop e
    fstp [inSum] ; 1/n^2k

    fld [temp]
    fsub [one]
    fstp [temp] 


   fld [inSum] 
   fadd [inRes]
   fstp [inSum] ; Сумма этих чисел
   mov cx, bx  
 loop d   
 fld [result]
 fmul [inSum]  
 fstp [result]
; Смотря на n  берем знак числа бернулли
  mov ax, [n]
  fild [n]
  fidiv word[two]
  fiadd word[one]
  fistp [n]  
  cmp ax, [n]
  jpo odd  
  mov [n], ax 

odd:
 fld [result]
 fchs   
 fstp [result]
; это я темп на место возвращаю
 mov cx, [n]
 fld [temp]
 f:  
  fadd [one]  
  loop f
  fstp [temp] 
}