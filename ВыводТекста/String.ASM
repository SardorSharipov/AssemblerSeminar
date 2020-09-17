format PE console
entry start

include 'WIN32A.inc'

section '.data' data readable writeable

   about        db 'Hi EveryBody',10
                db '',10,10
                db 'Press Enter',10,0

   main_str     db 'ѓ« ў­ п бва®Є : ',10,0                              ; Главная строка
   ext_str      db 10,10,'ђ биЁаҐ­ЁҐ д ©« :',10,0                       ; Расширение файла
   drive_str    db 10,10,'„ЁбЄ:',10,0                                   ; Диск
   path_str     db 10,10,'Љ в «®Ј:',10,0                                ; Каталог
   name_str     db 10,10,'€¬п д ©« :',10,0                              ; Имя
   path         db 'C:\programs\assembler\example\strings.asm',0
   buffer       rb 260

section '.code' code readable executable

  start:
        stdcall   Write, about
        stdcall   Read,buffer

        stdcall   Write, main_str
        stdcall   Write, path

        stdcall   Write, drive_str
        stdcall   ExtractFileDrive,buffer,path
        stdcall   Write,buffer

        stdcall   Write, path_str
        stdcall   ExtractFilePath,buffer,path
        stdcall   Write,buffer

        stdcall   Write, name_str
        stdcall   ExtractFileName,buffer,path
        stdcall   Write,buffer

        stdcall   Write, ext_str
        stdcall   ExtractFileExt,buffer,path
        stdcall   Write,buffer

  close:
        stdcall   Read,buffer
        invoke    ExitProcess,0

;==========================================
; Это процедура проводит проверку строки
; на кол-во знаков "\", в ecx - число
;==========================================

proc ScanDecimalStr buffer

     push       eax
     push       esi
     pushf
     cld
     mov        esi, [buffer]
     xor        ecx, ecx
   local
   .str_find_decimal:
     lodsb
     cmp        al, '\'
     je         .ok_separator
     cmp        al, '/'
     je         .ok_separator
     cmp        al, 0
     je         .end_find
     jmp        .str_find_decimal
   local
   .ok_separator:
     add        ecx, 1
     jmp        .str_find_decimal
   local
   .end_find:
     popf
     pop        esi
     pop        eax
     ret
endp

proc ExtractFileDrive buffer, path
     push       eax
     push       esi
     push       edi
     push       ecx
     pushf
     cld
     mov        esi,[path]
     mov        edi,[buffer]
     mov        ecx, 3
     rep        movsb
     mov        al,0
     stosb
     popf
     pop        ecx
     pop        edi
     pop        esi
     pop        eax
     ret
endp

proc ExtractFilePath buffer, path
     push       eax
     push       ecx
     push       esi
     push       edi
     pushf
     stdcall    ScanDecimalStr, [path]
   local
   extract_of_str:
     cld
     mov        esi, [path]
     mov        edi, [buffer]
   local
   extract_path:
     lodsb
     cmp        al, '\'
     je         dec_str
     cmp        al, '/'
     je         dec_str
     cmp        ecx, 0
     je         end_of_str
     stosb
     jmp        extract_path
   local
   dec_str:
     stosb
     sub        ecx, 1
     jmp        extract_path
   local
   end_of_str:
     mov        al, 0
     stosb
     popf
     pop        edi
     pop        esi
     pop        ecx
     pop        eax
     ret
endp

proc ExtractFileName buffer, path

     push       eax
     push       ecx
     push       esi
     push       edi
     pushf
     stdcall    ScanDecimalStr, [path]
   local
   .extract_of_str:
     cld
     mov        esi, [path]
     mov        edi, [buffer]
   local
   .extract_path:
     lodsb
     cmp        al, '\'
     je         .dec_str
     cmp        al, '/'
     je         .dec_str
     cmp        ecx, 0
     je         .extract_name
     jmp        .extract_path
   local
   .extract_name:
     stosb
     lodsb
     cmp        al, 0
     je         .end_of_str
     jmp        .extract_name
   local
   .dec_str:
     sub        ecx, 1
     jmp        .extract_path
   local
   .end_of_str:
     mov        al, 0
     stosb
     popf
     pop        edi
     pop        esi
     pop        ecx
     pop        eax
     ret
endp

proc ExtractFileExt buffer, path
     push       eax
     push       ecx
     push       esi
     push       edi
     pushf
     stdcall    ScanDecimalStr,[path]
     cld
     mov        esi,[path]
     mov        edi,[buffer]
   local
   .extract_ext_str:
     lodsb
     cmp        al, 0
     je         .ok_extract
     cmp        al, '\'
     je         .dec_decimal
     cmp        al, '/'
     je         .dec_decimal
     cmp        al, '.'
     je         .find_ok_ext
     jmp        .extract_ext_str
   local
   .find_ok_ext:
     stosb
     lodsb
     cmp        al, 0
     je         .ok_extract
     jmp        .find_ok_ext
   local
   .dec_decimal:
     sub        ecx, 1
     jmp        .extract_ext_str
   local
   .ok_extract:
     mov        al, 0
     stosb
     popf
     pop        edi
     pop        esi
     pop        ecx
     pop        eax
     ret
endp


include 'Win32.Consol.imp'
