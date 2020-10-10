macro output
{
mov [counter], 0
local ArrOut
local dontdelay
 ArrOut:
	mov ecx, [ebx]
	invoke printf, emptyStr, ecx
	add ebx,4
	inc [counter]
	mov eax, [counter]
	cmp eax,[i]
	je dontdelay
	invoke printf, spaceStr
	dontdelay:		 ;не разделять запятой
	cmp eax,[i]
	jl ArrOut
	invoke printf, enterStr
}