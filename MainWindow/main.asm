format PE GUI 4.0
entry start
include 'WIN32AX.INC'

section '.data' data readable writable

        class.form              db 'STORAGE',0
        title.form              db '������� ����',0

        hinstance               dd ?

        rc              RECT
        msg             MSG
        wc              WNDCLASS

section '.code' code readable executable

  start:
        invoke  GetModuleHandle,0
        mov     [hinstance],eax
        mov     [wc.hIcon],0
        invoke  LoadCursor,0,IDC_ARROW
        mov     [wc.hCursor],eax
        mov     [wc.style],0
        mov     [wc.lpfnWndProc],MainWindow
        mov     [wc.cbClsExtra],0
        mov     [wc.cbWndExtra],0
        mov     eax,[hinstance]
        mov     [wc.hInstance],eax
        mov     [wc.hbrBackground],COLOR_BTNFACE+1
        mov     [wc.lpszMenuName],0
        mov     [wc.lpszClassName],class.form

        ; ������� ����

        mov     [rc.right],500
        mov     [rc.bottom],390

        ; ����������� ���� �� � ����������

      aligne_x:
        invoke  GetSystemMetrics,SM_CXSCREEN    ; ������ ���������� � ������
        mov     ecx, eax
        shr     ecx, 1                          ; ����� � �� 2
        mov     eax, [rc.right]
        shr     eax, 1                          ; ����� ������ ����� �� 2
        sub     ecx, eax                        ; �������� �� �������� ������ ������ �������� ������ ����
        mov     [rc.left], ecx

        ; ����������� ���� �� Y ����������

      aligne_y:
        invoke  GetSystemMetrics,SM_CYSCREEN    ; ������ ���������� Y ������
        mov     ecx, eax
        shr     ecx, 1                          ; ����� Y �� 2
        mov     eax, [rc.bottom]
        shr     eax, 1                          ; ����� ������ ����� �� 2
        sub     ecx, eax                        ; ����������� �������� �� �������� ������ ������ �������� ������ ����
        mov     [rc.top], ecx
        invoke  RegisterClass,wc
        invoke  CreateWindowEx,0,class.form,title.form,WS_VISIBLE+WS_OVERLAPPEDWINDOW,[rc.left],[rc.top],[rc.right],[rc.bottom],0,0,[hinstance],0
  msg_loop:
        invoke  GetMessage,msg,NULL,0,0
        or      eax,eax
        jz      end_loop
        invoke  TranslateMessage,msg
        invoke  DispatchMessage,msg
        jmp     msg_loop
  end_loop:
        invoke  ExitProcess,0

proc MainWindow hwnd,wmsg,wparam,lparam
        push    ebx esi edi
        cmp     [wmsg],WM_DESTROY
        je      wmdestroy
        invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
        jmp     finish

  wmdestroy:
        invoke  PostQuitMessage,0
        xor     eax,eax
  finish:
        pop     edi esi ebx
        ret
endp

section '.idata' import data readable writeable

     library kernel32,'KERNEL32.DLL',\
             user32,'USER32.DLL',\
             shell32,'SHELL32.DLL'

include 'KERNEL32.inc'
include 'USER32.inc'
include 'SHELL32.inc'