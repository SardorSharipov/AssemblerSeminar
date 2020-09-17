
include 'WIN32AX.inc'
include 'dialogs.inc'

.data

        _class                  db 'FASTDLG32',0
        _title                  db 'Демострация диалогов',0
        _button                 db 'BUTTON',0
        _label                  db 'STATIC',0
        _edit                   db 'EDIT',0
        _error                  db 'Приложение вызвало ошибку и будет закрыто.',0
        _opendlg_title          db 'Открыть...',0
        _savedlg_title          db 'Сохранить...',0
        _printdlg_title         db 'Печать...',0
        _fontdlg_title          db 'Шрифт...',0
        _closebtn_title         db 'Выход',0
        FilterString            db "Текстовые файлы",0,"*.txt",0
                                db "Все файлы",0,"*.*",0,0

        _font                   db 'Comic Sans MS',0

        caption                 db 'Выбор папок...',0
        btext                   db 'Выберите нужную папку...',0

        hinstance               dd ?
        edithwnd                dd ?
        editfont                dd ?
        ID_OPEN                 = 50
        ID_SAVE                 = 51
        ID_PRINT                = 52
        ID_FONT                 = 53
        ID_EXIT                 = IDCLOSE

        wc WNDCLASS
        msg MSG

.code

  start:

        invoke  GetModuleHandle,0
        mov     [hinstance],eax
        invoke  LoadIcon,eax,17
        mov     [wc.hIcon],eax
        invoke  LoadCursor,0,IDC_ARROW
        mov     [wc.hCursor],eax
        mov     [wc.style],0
        mov     [wc.lpfnWndProc],WindowProc
        mov     [wc.cbClsExtra],0
        mov     [wc.cbWndExtra],0
        mov     eax,[hinstance]
        mov     [wc.hInstance],eax
        mov     [wc.hbrBackground],COLOR_BTNFACE+1
        mov     [wc.lpszMenuName],0
        mov     [wc.lpszClassName],_class
        invoke  RegisterClass,wc
        test    eax,eax
        jz      error
        invoke  LoadMenu,0
        invoke  CreateWindowEx,0,_class,_title,WS_VISIBLE+WS_MINIMIZEBOX+WS_EX_PALETTEWINDOW+WS_SYSMENU,244,228,456,240,NULL,eax,[hinstance],NULL     ;+
        test    eax,eax
        jz      error

  msg_loop:
        invoke  GetMessage,msg,NULL,0,0
        or      eax,eax
        jz      end_loop
        invoke  TranslateMessage,msg
        invoke  DispatchMessage,msg

        jmp     msg_loop
  end_loop:
        invoke  ExitProcess,[msg.wParam]

  error:
        invoke  MessageBox,NULL,_error,NULL,MB_ICONERROR+MB_OK
        invoke  ExitProcess,[msg.wParam]

proc WindowProc hwnd,wmsg,wparam,lparam
        push    ebx esi edi
        cmp     [wmsg],WM_CREATE
        je      .wmcreate
        cmp     [wmsg],WM_COMMAND
        je      .wmcommand
        cmp     [wmsg],WM_DESTROY
        je      wmdestroy

  .defwndproc:
        invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
        jmp     finish

  .wmcreate:

        invoke  CreateWindowEx,WS_EX_CLIENTEDGE,_button,_opendlg_title,WS_VISIBLE+WS_CHILD+WS_BORDER,10,10,100,30,[hwnd],ID_OPEN,[wc.hInstance],NULL
        invoke  CreateWindowEx,WS_EX_CLIENTEDGE,_button,_savedlg_title,WS_VISIBLE+WS_CHILD+WS_BORDER,10,50,100,30,[hwnd],ID_SAVE,[wc.hInstance],NULL
        invoke  CreateWindowEx,WS_EX_CLIENTEDGE,_button,_printdlg_title,WS_VISIBLE+WS_CHILD+WS_BORDER,10,90,100,30,[hwnd],ID_PRINT,[wc.hInstance],NULL
        invoke  CreateWindowEx,WS_EX_CLIENTEDGE,_button,_fontdlg_title,WS_VISIBLE+WS_CHILD+WS_BORDER,10,130,100,30,[hwnd],ID_FONT,[wc.hInstance],NULL
        invoke  CreateWindowEx,WS_EX_CLIENTEDGE,_button,_closebtn_title,WS_VISIBLE+WS_CHILD+WS_BORDER,10,170,100,30,[hwnd],ID_EXIT,[wc.hInstance],NULL

        invoke  CreateWindowEx,0,_label,_opendlg_title,WS_VISIBLE+WS_CHILD,130,10,100,30,[hwnd],0,[wc.hInstance],NULL
        invoke  CreateWindowEx,0,_label,_savedlg_title,WS_VISIBLE+WS_CHILD,130,50,100,30,[hwnd],0,[wc.hInstance],NULL
        invoke  CreateWindowEx,0,_label,_printdlg_title,WS_VISIBLE+WS_CHILD,130,90,100,30,[hwnd],0,[wc.hInstance],NULL
        invoke  CreateWindowEx,0,_label,_fontdlg_title,WS_VISIBLE+WS_CHILD,130,130,100,30,[hwnd],0,[wc.hInstance],NULL
        invoke  CreateWindowEx,0,_label,_closebtn_title,WS_VISIBLE+WS_CHILD,130,170,100,30,[hwnd],0,[wc.hInstance],NULL

        invoke  CreateWindowEx,WS_EX_CLIENTEDGE,_edit,0,WS_VISIBLE+WS_CHILD+WS_HSCROLL+WS_VSCROLL+ES_AUTOHSCROLL+ES_AUTOVSCROLL+ES_MULTILINE,210,10,230,190,[hwnd],0,[wc.hInstance],NULL
        or      eax,eax
        jz      .failed
        mov     [edithwnd],eax

        invoke  CreateFont,16,5,0,0,0,FALSE,FALSE,FALSE,ANSI_CHARSET,OUT_RASTER_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FIXED_PITCH+FF_DONTCARE,_font
        or      eax,eax
        jz      .failed
        mov     [editfont],eax
        invoke  SendMessage,[edithwnd],WM_SETFONT,eax,FALSE
        jmp     finish
      .failed:
        or      eax,-1
        jmp     finish

  .wmcommand:
        mov     eax,[wparam]
        and     eax,0FFFFh
        cmp     eax, ID_OPEN
        je      open_file
        cmp     eax, ID_SAVE
        je      save_file
        cmp     eax, ID_PRINT
        je      print_file
        cmp     eax, ID_FONT
        je      font
        cmp     eax, ID_EXIT
        je      wmdestroy
        jmp     .defwndproc

  open_file:
        GetFileName [hwnd],_opendlg_title,FilterString
        jmp finish

  save_file:
       SaveFileName [hwnd],_savedlg_title,FilterString
       jmp finish

  print_file:
        PageSetupDialog         [hwnd],psd,0,lMargin,tMargin,rMargin,bMargin
        PrintDialog             [hwnd],pd,PD_SHOWHELP
        jmp finish

  font:
        invoke  DeleteObject,[editfont]
        Fontdlg [hwnd],CF_BOTH + CF_SHOWHELP+CF_ANSIONLY+CF_SCRIPTSONLY+CF_FIXEDPITCHONLY+CF_NOSCRIPTSEL
        jmp finish

  wmdestroy:
        invoke  DeleteObject,[editfont]
        invoke  PostQuitMessage,0
        xor     eax,eax

  finish:
        pop     edi esi ebx
        ret

endp

.end start

