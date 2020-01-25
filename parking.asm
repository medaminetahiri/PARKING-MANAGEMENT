
;********************************************************************************
;																				*	
;																				*
;							     GESTION DE PARKING        			            *
;									     		                         	 	*
;																				*
;																				*
;********************************************************************************
;																				*	
;								TAHIRI MOHAMED AMINE							*
;																				*
;																				*
;********************************************************************************
	
	
	LIST      p=16F84            ; Definition de processeur
	#include <p16F84.inc>        ; Definitions de variables

	__CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC
	
	OPTIONVAL	 EQU H'38'    ;    0 0 1 0 1 0 0 0
	INTERMASK    EQU H'B0'	  ;	   1 0 1 1 0 0 0 0	
	TMR0INIT	 EQU H'FF'	  ;	   255
	PLACESDISP	 EQU H'0A'	  ;    10 places dispo


	CBLOCK 0x0C   			  ; debut de la zone variables
	
	w_temp 		: 1				
	status_temp : 1	
	compt		: 1
	compt1		: 1
	compt2		: 1
					
    
	ENDC					; Fin de la zone    

;**********************************************************************
;                      DEMARRAGE SUR RESET                            *
;**********************************************************************

	org 	0x000 			; Adresse de d?part apr?s reset
  	goto    init			; Adresse 0: initialiser

;**********************************************************************
;                      REGIME DINTERUPTION                            *
;**********************************************************************

	org		0x004
	movwf 	w_temp
	swapf	STATUS,w
	movwf	status_temp
	
	call 	inter
	
	swapf 	status_temp,w
	movwf 	STATUS
	swapf 	w_temp,f
	swapf 	w_temp,w
	retfie

inter
	btfss	INTCON,1
	goto	intertmr0
	goto 	interRB0

intertmr0
	call 	tempo
	bcf		INTCON,2
	movlw	TMR0INIT
	movwf	TMR0
	movf	compt,w
	sublw	PLACESDISP		; w=PLACESDISP-w
	btfss	STATUS,2
	call	open
	return

open
	bsf		PORTA,2
	call	tempo
	bcf		PORTA,2	
	incf	compt
	movf	compt,w
	sublw	PLACESDISP		; w=PLACESDISP-w
	btfss	STATUS,2
	return
	call	FR
	sleep
	return
	
FV
	bcf		PORTA,0
	bsf		PORTA,1
	return
FR
	bcf		PORTA,1
	bsf		PORTA,0	
	return
	
interRB0
	call 	tempo
	bcf		INTCON,1
	bsf		PORTA,3
	call	tempo
	bcf		PORTA,3
	decf	compt
	call	FV
	return
	
tempo
	movlw	.255
	movwf	compt1
boucle2
	clrf	compt2
boucle1
	decfsz	compt2
	goto 	boucle1
	decfsz	compt1
	goto	boucle2
	return	
	

;*********************************************************************
;                       Diminuer la consommation                     *
;*********************************************************************	

init
	clrf	EEADR				; permet de diminuer la consommation
	bsf		STATUS,RP0			; sélectionner banque 1
	movlw	OPTIONVAL			; charger masque
	movwf	OPTION_REG			; initialiser registre option							; sauter au programme principal
	movlw 	INTERMASK
	movwf	INTCON
	clrf	TRISB
	bsf		TRISB,0
	clrf	TRISA
	bsf		TRISA,4
	movlw	0x0c				; initialisation pointeur
	movwf	FSR					; pointeur d'adressage indirec

;*********************************************************************
;                         EFFACEER LA RAM                            *
;*********************************************************************

init1
	clrf	INDF				; effacer ram
	incf	FSR,f				; pointer sur suivant
	btfss	FSR,4				; tester si fin zone atteinte (>=40)
	goto	init1				; non, boucler
	btfss	FSR,0				; tester si fin zone atteinte (>=50)
	goto	init1				; non, boucler

	bcf 	STATUS,5
	movlw	TMR0INIT
	movwf	TMR0
	clrf	PORTA
	call	FV
	goto	START


;*********************************************************************
;                         PROGRAMME PRINCIPALE                       *
;*********************************************************************


START	
	goto	START
	
	END
