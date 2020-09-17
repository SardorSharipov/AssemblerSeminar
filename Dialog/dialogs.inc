_data:
      buffer		      db ?
    ;  patch                   db ?

      lMargin		      db ?
      tMargin		      db ?
      rMargin		      db ?
      bMargin		      db ?

      param_buffer	      rd 10h
      user_colors	      rd 40h
      name_buffer	      rb 100h
      search_string	      rb 1000h
      replace_string	      rb 1000h
      string_buffer	      rb 1000h
      help_path 	      rb 1000h
      ini_path		      rb 1000h
      path_buffer	      rb 4000h
      lpfont		      dd ?

      ofn	    OPENFILENAME
      pd	    PRINTDLG
      psd	    PAGESETUPDLG
      lfnt	    CHOOSEFONT

_code:


macro GetFileName hParent,lpTitle,lpFilter
{
    CanCreateofnDlg lpTitle,lpFilter
    mov     [ofn.lpstrFile],path_buffer
    mov     [path_buffer],0
    mov     [ofn.lpstrFilter],FilterString
    mov     [ofn.Flags],OFN_EXPLORER+OFN_ALLOWMULTISELECT+OFN_FILEMUSTEXIST+OFN_HIDEREADONLY
    mov     [ofn.lpstrFileTitle],name_buffer
    mov     [ofn.lpstrTitle],NULL
    invoke  GetOpenFileName,ofn
}


macro SaveFileName hParent,lpTitle,lpFilter
{
    CanCreateofnDlg lpTitle,lpFilter
    mov   [ofn.lStructSize],	    sizeof.OPENFILENAME
    mov   eax,[hwnd]
    mov   [ofn.hwndOwner],eax
    mov   eax,[hinstance]
    mov   [ofn.hInstance],eax
    mov   [ofn.lpstrFilter],	    lpFilter
    mov   [ofn.lpstrFile],	    path_buffer
    mov   [ofn.nMaxFile],	    1000h
    mov   [ofn.lpstrTitle],	    lpTitle
    mov   [ofn.Flags],		    OFN_EXPLORER or OFN_LONGNAMES
				
    invoke GetSaveFileName,ofn

}

macro  CanCreateofnDlg _Title, _Filter
{
	mov	[ofn.lStructSize],sizeof.OPENFILENAME
	mov	eax,[hwnd]
	mov	[ofn.hwndOwner],eax
	mov	eax,[hinstance]
	mov	[ofn.hInstance],eax
	mov	[ofn.lpstrCustomFilter],NULL
	mov	[ofn.nFilterIndex],1
	mov	[ofn.nMaxFile],1000h
	mov	[ofn.lpstrFileTitle],_Title
	mov	[ofn.nMaxFileTitle],100h
	mov	[ofn.lpstrInitialDir],NULL
	mov	[ofn.lpstrDefExt],_Filter
	mov	[param_buffer],48h
	mov	[param_buffer+4],90h
	mov	[param_buffer+8],-1
}

macro PrintDialog hWin,lppd,flags
{

  ; ------------------------------------------------------------------
  ; Parameters
  ; 1. hWin  = parent handle
  ; 2. lppd  = address of PRINTDLG to receive info
  ; 3. flags = additional styes from the PRINTDLG reference material
  ;
  ; EXAMPLE: invoke PrintDialog,hWin,ADDR pd,PD_SHOWHELP
  ; ------------------------------------------------------------------

    mov [pd.lStructSize],	      sizeof.PRINTDLG
    mov eax,			      [hwnd]
    mov [pd.hwndOwner], 	      eax
    mov [pd.hDevMode],		      0
    mov [pd.hDevNames], 	      0
    mov [pd.hDC],		      0
    mov eax,			      flags
    or	eax,			      PD_PAGENUMS			 ; "or" default value with extra flags
    mov [pd.Flags],		      eax
    mov [pd.nFromPage], 	      1
    mov [pd.nToPage],		      1
    mov [pd.nMinPage],		      0
    mov [pd.nMaxPage],		      65535
    mov [pd.nCopies],		      1
    mov [pd.hInstance], 	      0
    mov [pd.lCustData], 	      0
    mov [pd.lpfnPrintHook],	      0
    mov [pd.lpfnSetupHook],	      0
    mov [pd.lpPrintTemplateName],     0
    mov [pd.lpPrintTemplateName],     0
    mov [pd.hPrintTemplate],	      0
    mov [pd.hSetupTemplate],	      0

    invoke PrintDlg, pd.lStructSize
}

macro PageSetupDialog hWin,lppsd,style,lMargin,tMargin,rMargin,bMargin
{										      ; Parameters.
										      ; ~~~~~~~~~~
    mov [psd.lStructSize],		  sizeof.PAGESETUPDLG			      ; 1. hWin    = Parent window handle.
    push hWin									      ; 2. lppsd   = address of PAGESETUPDLG structure for return parameters
    pop [psd.hwndOwner] 							      ; 3. style   = Default is 0, else styles from PAGESETUPDLG reference.
    mov [psd.hDevMode], 		  0					      ; 4. lMargin = 0 defaults to 500, inch = 1000
    mov [psd.hDevNames],		  0					      ; 4. tMargin = 0 defaults to 500, inch = 1000
    or eax, PD_SHOWHELP+PD_ALLPAGES+PD_SELECTION+PD_PAGENUMS			      ; 4. rMargin = 0 defaults to 500, inch = 1000
    mov [psd.Flags],			  eax					      ; 4. bMargin = 0 defaults to 500, inch = 1000
    mov [psd.ptPaperSize.x],		  0
    mov [psd.ptPaperSize.y],		  0					      ; EXAMPLE : invoke PageSetupDialog,hWin,ADDR psd,0,1000,750,1000,750
    mov [psd.rtMinMargin.left], 	  0
    mov [psd.rtMinMargin.top],		  0
    mov [psd.rtMinMargin.right],	  0
    mov [psd.rtMinMargin.bottom],	  0

    push lMargin
    pop [psd.rtMargin.left]

    push tMargin
    pop [psd.rtMargin.top]

    push rMargin
    pop [psd.rtMargin.right]

    push bMargin
    pop [psd.rtMargin.bottom]

    mov [psd.hInstance],		  0
    mov [psd.lCustData],		  0
    mov [psd.lpfnPageSetupHook],	  0
    mov [psd.lpfnPagePaintHook],	  0
    mov [psd.lpPageSetupTemplateName],	  0
    mov [psd.hPageSetupTemplate],	  0

    invoke PageSetupDlg, psd
}

macro Fontdlg hWin,fStyle
{
    invoke GetDC,hWin
    push eax
    xchg  ebx, eax
    mov [lfnt.lStructSize],	    sizeof.CHOOSEFONT
    push hWin
    pop [lfnt.hwndOwner]
    mov [lfnt.hDC],		    eax
    push lfnt
    pop [lfnt.lpLogFont]
    mov [lfnt.iPointSize],	    0
    push fStyle
    pop [lfnt.Flags];,               CF_BOTH+CF_SHOWHELP+CF_EFFECTS+CF_ANSIONLY+CF_SCRIPTSONLY+CF_FIXEDPITCHONLY+CF_NOSCRIPTSEL
    mov [lfnt.rgbColors],	    COLOR_BTNFACE+2
    mov [lfnt.lCustData],	    0
    mov [lfnt.lpfnHook],	    0
    mov [lfnt.lpTemplateName],	    0
    mov [lfnt.hInstance],	    0
    mov [lfnt.lpszStyle],	    0
    mov [lfnt.nFontType],	    0
    mov [lfnt.wReserved],	    0
    mov [lfnt.nSizeMin],	    0
    mov [lfnt.nSizeMax],	    0

    invoke ChooseFont,lfnt
    mov    [lpfont], eax
    invoke ReleaseDC,hWin,ebx

    ;Fontdlg,hWin,CF_BOTH + CF_FIXEDPITCHONLY          ; ChooseFont,'ChooseFontA',\    comdlg32
}


