;	This is pclock. This project main aim is to 
;	lock the pc by boot. The is just support the 
;	bios boot system, now just use in Windows NT 
;	boot on the bios.

;	It's really hard for me to write this code,
;	Because i think i am be familer whit the C
;	Langugage but not assmbely language.


;*****************************************
;     LICENSE : GPL-V3                   ;
;     Author  :  Bobi Tian & Hacking     ;
;     This is Free SoftWare              ;
;*****************************************






%define VEDIO_SEG_ADR			0B800H
%define PASS_WORD_8BITS		08H
%define CMPRSULT_OK			01H
%define CMPRSULT_NO			00H
%define MBR_SEG_ADR			07c0H
%define INI3_FUNC_NO			00H
%define FIRST_HD_NO			80H
%define HD_HEAD_NO			00H
%define KEYBORAD_INITER		16H
%define XXXADDR				1664

%define KEYBORAD_ENTER		1ch
%define KEYBORAD_BACK			0eh

%define PASS_WORD_MAX			10h

%define LOCK_EFA				1346
			
%define MBR_RELOCAK			7c00h


init_the_seg:
		mov 	ax, 0x70
		cli										;Disable interput. When we adjust the Stack Section.
		mov 	ss, ax
		mov		sp, 0
		mov		bp, 0
		sti										;Enable interupt.
		
init_lock:
		mov 	cx, 14
		mov 	ax, VEDIO_SEG_ADR
		mov 	ds, ax
		mov		bx, LOCK_EFA
		mov 	ax, MBR_SEG_ADR
		mov		es, ax
		mov 	di, _message
		
set_lock_scan_ad:
		mov 	BYTE al,[es:di]
		mov 	BYTE [ds:bx], al
		inc		di
		add 	bx, 2
		dec		cx
		jnz 	set_lock_scan_ad
		
in_keybord:
		mov 	cx, PASS_WORD_MAX
		mov		ax, VEDIO_SEG_ADR
		mov		ds, ax
		mov		bx, XXXADDR
		mov 	ax, MBR_SEG_ADR
		mov	 	es, ax
		mov		di, repasswd_
		
		
		
		
test_cx:
		mov		ah, 0
		int		KEYBORAD_INITER


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                                          
;re_test:																
; 		mov 	cx, 8h													
; 		mov 	bx, 0													
;localtest:															
; 		rcl		ah, 1													
; 		jc		cfset													
; 		mov		BYTE [bx], '0'										
; 		jmp 	lelele													
;cfset:																
; 		mov 	BYTE [bx], '1'										
;lelele:																
; 		add 	bx, 2												
; 		dec 	cx													
; 		jz 		in_keybord												
; 		jmp 	localtest											
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

test_one:
		cmp		ah, KEYBORAD_BACK
		jz		lf1
		jmp 	test_two
		
lf1:	
		cmp 	cx, PASS_WORD_MAX
		jz 		test_cx
		dec		di
		sub		bx, 02h
		inc		cx
		mov		BYTE [ds:bx], 20h
		mov 	BYTE [es:di], 00h
break1:	
		jmp		test_cx
		

test_two:
		cmp 	ah, KEYBORAD_ENTER
		jnz		test_three
		jmp 	move_pass_to_repass

		

test_three:
		cmp 	cx, 0h
		jz		break3
		mov BYTE[ds:bx], al
		mov BYTE[es:di], al
		dec		cx
		inc		di
		add 	bx, 2h
break3:
		jmp 	test_cx

move_pass_to_repass:

		

		
go_to_test_password:

		push	WORD here_push_ip + 7c00h

		jmp		cmpstr
here_push_ip:
		
		test 	ax, CMPRSULT_OK

		jnz		chainloader
		;reboot
		jmp 	0FFFFH:0000H





cmpstr:

		mov		cx, 16
		cld
		mov 	ax, MBR_SEG_ADR
		mov 	ds, ax
		mov		es, ax
		mov		si, repasswd_
		mov		di, passwd_
	
		repz	cmpsb 
		jnz		return_no
		
return_ok:
		mov		ax, CMPRSULT_OK
		ret
return_no:

		mov 	ax, CMPRSULT_NO
		ret		

		
		; This use to chain load the really Windows System Loader.
		; mov the MBR relocal to 0600h:0000h
chainloader:
		;debug
		push	ax
		mov 	ax, VEDIO_SEG_ADR
		push	ds
		mov		ds, ax
		
		mov 	BYTE[00h],'L'
		mov		BYTE[02h],'D'
		pop		ax
		pop		ds
		;debug
		
		xor 	ax,ax
		cli
		mov 	ss,ax
		mov 	sp,MBR_RELOCAK
		sti
		mov 	es,ax
		mov 	ds,ax
		mov 	si,MBR_RELOCAK
		mov 	di,0x600
		mov 	cx,0x200
		cld
		rep 	movsb
		push 	ax
		push 	word here_retf + 0x600
		retf
here_retf:
		sti
	
chain:
		mov 	ax, MBR_SEG_ADR				;make ax = 0x7c0
		mov 	es, ax							;to make es:bx = 0x7c00, we move the second sector to 0x7c00,this is the key to chain loader.
		mov 	bx, INI3_FUNC_NO 				;bx = 0
		mov 	dl, FIRST_HD_NO  				;the disk number, the 0x80 for the first hard disk, the 0 for solf disk.
		mov 	dh, HD_HEAD_NO				;the number of the head disk.
		mov 	ch, 0 							;the number of disk runtine.
		mov 	cl, 2 							;the number of sector.
		mov 	al, 1 							;the numbers of the sector to read or write.
		mov 	ah, 2 							;the call int 13 function parament.

		int 	0x13							;ok, looks work fine.
		jmp 	0x7c0:0x00
		
;This areal is for passwd.


_message: db 'WINDOWS   LOCK'
repasswd_:
		times PASS_WORD_8BITS dw 0x00
		
		db	0x00
		
passwd_:
		times 			10h			db 'A'
		db	0x00

magic_:
		times 510-($-$$) db 0
		db 0x55
		db 0xaa

		
		




