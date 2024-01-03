;-----------------------------------------------------------------------
; afficher l'heure a l'ecran
;-----------------------------------------------------------------------

; titre
TITLE		DISPLAY - programme prototype
.286

;-------------------------------------------------------STACK segment
SSEG	SEGMENT		STACK
	DB			32 DUP("STACK---")
SSEG	ENDS

;-------------------------------------------------------DATA segment
DSEG	SEGMENT

DATE DB			"Date du jour: "
L_DATE EQU		$-DATE

MESSAGE DB			"Voici l'heure actuelle en France: "
L_MESSAGE EQU		$-MESSAGE

MENU_MESSAGE DB			"APPUIER SUR LE NOMBRE QUI CORRESPOND AU ELEMENT DU MENU"
L_MENU_MESSAGE EQU		$-MENU_MESSAGE

MENU_HORAIRE DB			"1) HORAIRE"
L_MENU_HORAIRE EQU		$-MENU_HORAIRE

MENU_CHRONO DB			"2) CHRONOMETRE"
L_MENU_CHRONO EQU		$-MENU_CHRONO

HEURE DB				0
MINUTE DB				0
SECONDE DB				0

HEURE_CHRONO DB			0
MINUTE_CHRONO DB		0
SECONDE_CHRONO DB		0

DSEG	ENDS

;-------------------------------------------------------CODE segment
CSEG SEGMENT	'CODE'
ASSUME	CS:CSEG, SS:SSEG, DS:DSEG

;-----------------------------------------------------------------------
; procedure MAIN
MAIN PROC FAR
    ; sauver l'adresse de retour
    PUSH DS
    PUSH 0
    
    ; registre
    MOV	AX,DSEG
    MOV	DS,AX

    ; vide écran
    call VIDE_ECRAN

    ; positionnement du message du menu
    mov dh, 10	;ligne
    mov dl, 20	;colonne
    mov bh, 0	;page
    mov ah, 2	;set le curseur
    int 10h

    ; message menu
    MOV BX, 0001H
    LEA DX, MENU_MESSAGE
    MOV CX, L_MENU_MESSAGE
    MOV AH, 40H
    INT 21H

    ; positionnement du message du menu
    mov dh, 14	;ligne
    mov dl, 20	;colonne
    mov bh, 0	;page
    mov ah, 2	;set le curseur
    int 10h

    ; message menu
    MOV BX, 0001H
    LEA DX, MENU_HORAIRE
    MOV CX, L_MENU_HORAIRE
    MOV AH, 40H
    INT 21H

    ; positionnement du message du menu
    mov dh, 15	;ligne
    mov dl, 20	;colonne
    mov bh, 0	;page
    mov ah, 2	;set le curseur
    int 10h

    ; message menu
    MOV BX, 0001H
    LEA DX, MENU_CHRONO
    MOV CX, L_MENU_CHRONO
    MOV AH, 40H
    INT 21H

	choixMenu:
		call reinit_pos

		; lecture du caractère
		mov ah, 01h  
		int 21h

		cmp al, '1'
		je horaireDebut

		cmp al, '2'
		je chronoDebut

		jmp choixMenu

horaireDebut:
    call VIDE_ECRAN
    ; on cache le curseur du texte
    mov ch, 32
    mov ah, 1
    int 10h
    ; positionnement du message de la date
    mov dh, 08	;ligne
    mov dl, 20	;colonne
    mov bh, 0	;page
    mov ah, 2	;set le curseur
    int 10h
    ; message date
    MOV BX, 0001H
    LEA DX, DATE
    MOV CX, L_DATE
    MOV AH, 40H
    INT 21H		

    call montreDate

    ; positionnement du message
    mov dh, 10	;ligne
    mov dl, 20	;colonne
    mov bh, 0	;page
    mov ah, 2	;set le curseur
    int 10h
    ; message
    MOV BX, 0001H
    LEA DX, MESSAGE
    MOV CX, L_MESSAGE
    MOV AH, 40H
    INT 21H

    boucleHoraire:
        ; on positionne au centre en dessous du message
        call reinit_pos

        mov ah, 2ch ;temps du système
        int 21h

        ; On montre les heures
        mov al, ch
        call affi
        mov dl, ':'
        mov ah, 02h
        int 21h

        ; On montre les minutes
        mov al, cl
        call affi
        mov dl, ':'
        mov ah, 02h
        int 21h

        ; On montre les secondes
        mov al, dh
        call affi

        JMP boucleHoraire ; On recommence le code de la boucle

chronoDebut:
    ; vide écran
    call VIDE_ECRAN
    ; on cache le curseur du texte
    mov ch, 32
    mov ah, 1
    int 10h
   
	call montreDate

	; boucle chrono
	boucleChrono:
	
	    ; positionnement du CHRONO
		mov dh, 10	;ligne
		mov dl, 20	;colonne
		mov bh, 0	;page
		mov ah, 2	;set le curseur
		int 10h
		
	    mov ah, 2ch ;temps du système
        int 21h

		mov ch, 0
		mov cl, 0
		mov dh, 0

        ; On montre les heures
        mov al, ch
        call affi
        mov dl, ':'
        mov ah, 02h
        int 21h

        ; On montre les minutes
        mov al, cl
        call affi
        mov dl, ':'
        mov ah, 02h
        int 21h

        ; On montre les secondes
        mov al, dh
        call affi

	    mov ah, 2ch ;temps du système
        int 21h
        
        mov HEURE, ch
        mov MINUTE, cl
        mov SECONDE, dh
        
		controleChrono:
			mov ah, 2ch ;temps du système
			int 21h
			
			controleHeure:
				cmp ch, HEURE
				jg ajoutHeure
				
				jmp controleMinute
		
			controleMINUTE:
				cmp cl, MINUTE
				jg ajoutMinute
				
				jmp controleSeconde	

			controleSECONDE:
				cmp dh, SECONDE
				jg ajoutSeconde
				
				jmp controleChrono	

			ajoutHeure:
				mov HEURE, ch
				mov dh, 10
				mov dl, 20	;colonne
				mov bh, 0	;page
				mov ah, 2	;set le curseur
				int 10h
				mov ah, 2ch ;temps du système
				int 21h
				add HEURE_CHRONO,1
				mov ch, HEURE_CHRONO
				mov cl, MINUTE_CHRONO
				mov dh, SECONDE_CHRONO

				; On montre les heures
				mov al, ch
				call affi
				mov dl, ':'
				mov ah, 02h
				int 21h

				; On montre les minutes
				mov al, cl
				call affi
				mov dl, ':'
				mov ah, 02h
				int 21h

				; On montre les secondes
				mov al, dh
				call affi
				jmp controleChrono
				
			ajoutMinute:
				mov MINUTE, cl
				mov dh, 10
				mov dl, 20	;colonne
				mov bh, 0	;page
				mov ah, 2	;set le curseur
				int 10h
				add MINUTE_CHRONO,1
				mov ah, 2ch ;temps du système
				int 21h
				mov ch, HEURE_CHRONO
				mov cl, MINUTE_CHRONO
				mov dh, SECONDE_CHRONO

				; On montre les heures
				mov al, ch
				call affi
				mov dl, ':'
				mov ah, 02h
				int 21h

				; On montre les minutes
				mov al, cl
				call affi
				mov dl, ':'
				mov ah, 02h
				int 21h

				; On montre les secondes
				mov al, dh
				call affi
				jmp controleChrono
				
			ajoutSeconde:
				mov SECONDE, dh
				mov dh, 10
				mov dl, 20	;colonne
				mov bh, 0	;page
				mov ah, 2	;set le curseur
				int 10h
				add SECONDE_CHRONO,1
				mov ah, 2ch ;temps du système
				int 21h
				mov ch, HEURE_CHRONO
				mov cl, MINUTE_CHRONO
				mov dh, SECONDE_CHRONO

				; On montre les heures
				mov al, ch
				call affi
				mov dl, ':'
				mov ah, 02h
				int 21h

				; On montre les minutes
				mov al, cl
				call affi
				mov dl, ':'
				mov ah, 02h
				int 21h

				; On montre les secondes
				mov al, dh
				call affi
				jmp controleChrono

		jmp boucleChrono
        
        jmp chronoDebut

affi proc
    push ax       ; Sauvegarde la valeur du registre AX dans la pile
    push bx       ; Sauvegarde la valeur du registre BX dans la pile

    ; Conversion de la valeur binaire en ASCII
    aam            ; On divise AL par 10
    
    mov bx, ax     ; On déplace le résultat de la division (AL) dans le registre BX
    add bx, 3030h  ; On convertit le résultat en ASCII en ajoutant 3030h (48 en décimal)

    mov dl, bh     ; On déplace le poids fort de BX dans le registre DL
    mov ah, 02h
    int 21h        ; On affiche le premier chiffre de la valeur convertie
    
    mov dl, bl     ; On déplace le poids faible de BX dans le registre DL
    mov ah, 02h
    int 21h        ; On affiche le deuxième chiffre de la valeur convertie

    pop bx        
    pop ax
    ret           ; Retourne de la procédure
affi endp

montreDate proc
    ; positionnement de la date
    mov dh, 08	;ligne
    mov dl, 34	;colonne
    mov bh, 0	;page
    mov ah, 2	;set le curseur
    int 10h

    mov ah, 2Ah     ; date, jour dans dl , mois dans dh, annee dans cx
    int 21h         ;

    mov al, dl      ; jour
    call affi
    mov dl, '/'
    mov ah, 02h
    int 21h

    mov al, dh      ; mois
    call affi
    mov dl, '/'
    mov ah, 02h
    int 21h

    add cx, 0F830h
    mov ax, cx      ; annee
    call affi

    ret
montreDate endp

reinit_pos proc
    ; on réinitialise la position du curseur
    mov dh, 11
    mov dl, 30
    mov bh, 0
    mov ah, 2
    int 10h
    ret
reinit_pos endp

VIDE_ECRAN PROC
    ; vide écran
    MOV AH, 0
    MOV AL, 2
    INT 10H
    RET
VIDE_ECRAN ENDP

; retour
RET
; fin de la procédure MAIN
MAIN ENDP
; fin du code du segment
CSEG ENDS
; fin du programme
END MAIN
; ------------------------------------------------------ fin de programme
