format PE GUI 4.0                               ;        ������ �����
entry start                                     ;        ����� � ������� ���������� ���������� ����
include 'WIN32A.inc'                  ;        ���� � ����� win32a.inc
                                                ;        � ��� ���������� ������ ��������� � �������

section '.data' data readable writable          ; ������ ������

        SzFile  db 'D:\�����\Assembler\Projects\FileMaker\file.txt',0              ; ������ ��� ����� ������� ����, ������ ������ ������������� �����
        buffer  db 'Hello World',0              ; ����� ���������� �����
        len_buf = $ - buffer                    ; ������ ������
        hfile   dd ?                            ; DWORD ����� ��� ���������� ������ �����

section '.code' code readable executable        ; ������ ����

  start:                                        ; ����� � ������� ��������� ����������
        invoke  _lcreat, SzFile, 0              ; ������� ����
        mov     [hfile], eax                    ; ��������� �����
        invoke  _lwrite, eax, buffer, len_buf   ; ���������� ������
        invoke  CloseHandle, [hfile]            ; ��������� ����

  close:                                        ; �����
        invoke  ExitProcess, 0                  ; ������� �� ���������

section '.idata' import data readable writeable ; ������ �������

  library kernel,'KERNEL32.DLL'                 ; ����������� ������� ������ �� ����� ���������� - KERNEL32.DLL

  import kernel,\
         _lcreat,'_lcreat',\                    ; _lcreat       - ������� ��� �������� �����
         _lwrite,'_lwrite',\                    ; _lwrite       - ������� ��� ������ � ����
         CloseHandle,'CloseHandle',\            ; CloseHandle   - ������� ��� �������� ������������
         ExitProcess,'ExitProcess'              ; ExitProcess   - ���������� ����������
