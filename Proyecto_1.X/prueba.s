;Archivo: Proyecto1.s
;Dispositivo: PIC16F887
;Autor: Josue Salazar
; Compilador: pic-as (v2.31), MPLABX v5.45
; 
; Programa: proyecto 1
; Hardware: 7 segmentos en el portd, leds en el portA , botones en el portB y transistores
;
;Creado: 15 mar, 2021
;Ultima Modificacion:    abril, 2021
    
PROCESSOR 16F887

#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
;--------------macros---------------------------------------------------

reiniciarT0 macro
    banksel PORTA	
    movlw   254		    ; valor inicial/ delay suficiente
    movwf   TMR0	    ; se coloca el valor en el inicio 
    bcf	    T0IF	    ; limpiar la bandera del timer para no sobre poner valores
    endm
reiniciarT1 macro
    banksel PORTA	
    movlw   238		    ; valor inicial/ delay suficiente este valor se divide en 2 bytes
    movwf   TMR1L
    movlw   133
    movwf   TMR1H
    bcf	    TMR1IF	 ; limpiar la bandera del timer para no sobre poner valores    
    endm
    
reiniciarT2 macro
    banksel TRISA	
    movlw   245	    ; valor inicial/ delay suficiente
    movwf   PR2	    ; colocar el valor inicial en el registro de comparacion
    
    banksel PORTA
    bcf	    TMR2IF  ; limpiar la bandera del timer para no sobre poner valores
    endm
GLOBAL var,banderas,dise,mood,UNI,DECE,PRUEBA,SEMA1,SEMA2,SEMA3,Tsema1,Tsema2
GLOBAL Tsema3,INTER,CONT,TVIA
    PSECT udata_shr    ;comoon memory
    W_TEM:	DS 1
    ESTATUS:	DS 1
    
PSECT udata_bank0
    var:      DS 3
    banderas: DS 2
    dise:     DS 8
    mood:     DS 1
    UNI:      DS 6
    DECE:     DS 6
    PRUEBA:   DS 1
    SEMA1:    DS 1
    SEMA2:    DS 1
    SEMA3:    DS 1
    Tsema1:   DS 1
    Tsema2:   DS 1
    Tsema3:   DS 1
    INTER:    DS 1
    CONT:     DS 3
    TVIA:     DS 3
    
    
    
    
 
    
  
  PSECT resVect, class=CODE, abs, delta=2
  ;--------------vector reset---------------------------------------------------
  ORG 00h	 ;posicion 0000h para el reset
  resetVec: 
      PAGESEL main
      goto main
PSECT intVect, class=CODE, abs, delta=2
;--------------vector interrupcion---------------------------------------------------
 ORG 04h
 
 push:
    movwf   W_TEM	    ; guardar valores en status 
    swapf   STATUS, W
    movwf   ESTATUS
    
 isr:
    
    btfsc   T0IF	    ; revisar bandera de Timer0
    call    inttimer	    ;interrupcion del timer
    
    btfsc TMR1IF	    ; revisar bandera de Timer1
    call inttimer1	    ;interrupcion del timer
    
    btfsc   TMR2IF	    ; revisar bandera de Timer2
    call inttimer2	    ;interrupcion del timer
    
pop:
    swapf   ESTATUS, W
    movwf   STATUS  
    swapf   W_TEM, F
    swapf   W_TEM, W
    retfie
;-------------------------sub rutinas INT-----------------------------------------

//<editor-fold defaultstate="collapsed" desc="MULTIPLEXADO">
inttimer:
  	      
    reiniciarT0
    bcf    PORTD,0
    bcf    PORTD,1
    bcf    PORTD,2
    bcf    PORTD,3
    bcf    PORTD,4
    bcf    PORTD,5
    bcf	   PORTD,6
    bcf	   PORTD,7
    ;Multiplexiar
    ; Crear un ciclo de condiciones
    btfsc   banderas,0		    ;If bandera,0 entonces ir al display 1
    goto    disp1
    btfsc   banderas,1		    ;If bandera,1 entonces ir al display 2
    goto    disp2
    btfsc   banderas,2		    ;If bandera,2 entonces ir al display 3  
    goto    disp3
    btfsc   banderas,3		    ;If bandera,3 entonces ir al display 4
    goto    disp4
    btfsc   banderas,4		    ;If bandera,4 entonces ir al display 5
    goto    disp5
    btfsc   banderas,5		    ;If bandera,4 entonces ir al display 5
    goto    disp6
    btfsc   banderas,6		    ;If bandera,4 entonces ir al display 5
    goto    disp7
disp0:
    movf	dise,W		    ; mover el valor a W para colocarlo en el PORTC
    movwf	PORTC
    bsf		PORTD,0		    ; revisar si el bit del transitor que controla el display esta encendido
    goto	sigdis1		    ; ir a siguiente display 
	
	
disp1:
    movf	dise+1,W
    movwf	PORTC
    bsf		PORTD,1
    goto	sigdis2
disp2:
    movf	dise+2,W
    movwf	PORTC
    bsf		PORTD,2
    goto	sigdis3
disp3:
    movf	dise+3,W
    movwf	PORTC
    bsf		PORTD,3
    goto	sigdis4
disp4:
    movf	dise+4,W
    movwf	PORTC
    bsf		PORTD,4
    goto	sigdis5
disp5:
    movf	dise+5,W
    movwf	PORTC
    bsf		PORTD,5
    goto	sigdis6
disp6:
    movf	dise+6,W
    movwf	PORTC
    bsf		PORTD,6
    goto	sigdis7
disp7:
    movf	dise+7,W
    movwf	PORTC
    bsf		PORTD,7
    goto	sigdis0
	
sigdis1:
    movlw   1		;mover 1 a w y realizar un XOR guardado en F 
    xorwf   banderas,F
    return
sigdis2:
    movlw   3
    xorwf   banderas,F
    return
sigdis3:
    movlw   6
    xorwf   banderas,F
    return
sigdis4:
    movlw   12
    xorwf   banderas,F
    return
sigdis5:
    movlw   24
    xorwf   banderas,F
    return
sigdis6:
    movlw   48
    xorwf   banderas,F
    return
sigdis7:
    movlw   96
    xorwf   banderas,F
    return
	
	
sigdis0:
    clrf	banderas,F
	
    return  
    
    //</editor-fold>
 
	
inttimer1:
    reiniciarT1		;reiniciar para colocar un valor nuevo	
    decf SEMA1, F		; incrementar en el contador
    decf SEMA2, F
    decf SEMA3, F
    return
inttimer2:
    reiniciarT2		; reiniciar
    
    btfsc   INTER,0	;revisar banderas, si esta apagada entonces 
    goto ON
OFF:
    bsf	    INTER,0	; setear la bandera 
    return
ON:
    bcf	    INTER,0	; limpiar la bandera
    return

    
    
  PSECT code, delta=2, abs
  ORG 100h	; posicion para la tabla 
  tabla: 
    clrf    PCLATH
    bsf	    PCLATH,0 ; PCLATH = 01
    andlw   0x0f
    addwf   PCL 
    retlw   00111111B ;0
    retlw   00000110B ;1
    retlw   01011011B ;2
    retlw   01001111B ;3
    retlw   01100110B ;4
    retlw   01101101B ;5
    retlw   01111101B ;6
    retlw   00000111B ;7
    retlw   01111111B ;8
    retlw   01101111B ;9
    retlw   01110111B ;A
    retlw   01111100B ;B
    retlw   00111001B ;C
    retlw   01011110B ;D
    retlw   01111001B ;E
    retlw   01110001B ;F
    
  /*PSECT code, delta=2, abs
    ORG 114h */
  ;------------configuracion----------------------------------------------------
main:	
   
    call io	    ; llamar las congiguraciones de entrada y salida	
    call conclock   ; llamar las congiguraciones del reloj interno
    call contimer   ; llamar las congiguraciones deL TIMER0
    call coninten   ; llamar las congiguraciones de banderas de interrupciones
    call contimer1  ; llamar las congiguraciones deL TIMER1
    call contimer2  ; llamar las congiguraciones deL TIMER2
    
    movlw   15
    movwf   TVIA
    movwf   SEMA1
    movwf   SEMA2
    
    movlw   20
    movwf   TVIA+1
    
    movlw   15
    movwf   TVIA+2
    
    movlw   35
    movwf   SEMA3
    
    bsf	    CONT,0
    
   banksel PORTA    
    ;----------loop principal---------------------------------------------------
loop: 

    btfss   PORTB,0
    call    cambiarmodo
    
    call    VALSEMA
    call    DISPSEMA

;    btfsc   CONT,0
;    call    V1
;    
;    btfsc   CONT,1
;    call    VI1
;    
;    btfsc   CONT,2
;    call    A1
;    
;    btfsc   CONT,3
;    call    V2
;    
;    btfsc   CONT,4
;    call    VI2
;    
;    btfsc   CONT,5
;    call    A2 
;    
;    btfsc   CONT,6
;    call    V3
;    
;    btfsc   CONT,7
;    call    VI3
;    
;    btfsc   CONT+1,0
;    call    A3
    
;    btfsc   mood,0
;    goto    moodA
;    goto    moodB
    


    
//<editor-fold defaultstate="collapsed" desc="Cambio de modo">
cambiarmodo:
    btfss	PORTB,0
    goto	$-1
    incf	var
    call	lims
    
    movf	var,W
    return
    //</editor-fold>

//<editor-fold defaultstate="collapsed" desc="INC/DEC">
inc:
    btfss   PORTB,1
    goto    $-1
    incf    var
    call    lims
    
    movf    var,W
    return
    
decr:
    btfss   PORTB,2
    goto    $-1
    decf    var
    call    limi
    
    movf    var,W
    return
    
    //</editor-fold>

//<editor-fold defaultstate="collapsed" desc="limites">
limi:
    movlw   9
    subwf   var,W
    
    btfsc   STATUS,2
    goto    ufl
    
    return
    
ufl:
    movlw   20
    movwf   var
    return
    
lims:
    movlw    21
    subwf    var,W
   
    btfsc    STATUS,2
    goto	    ofl
   
    return
   
ofl:
    movlw   10
    movwf   var
    return
    //</editor-fold>
 
;//<editor-fold defaultstate="collapsed" desc="VM">
;moodA:
;    btfsc   mood,1
;    goto    moodD
;    goto    moodC
;    goto    loop
;    
;moodB:
;    btfsc   mood,1
;    goto    moodE
;    goto    moodF
;    goto    loop
;    
;moodC:
;    btfsc   mood,2
;    goto    mood4
;    goto    mood0
;    goto    loop
;    
;moodD:
;    btfsc   mood,2
;    goto    moodm
;    goto    mood2
;    goto    loop
;  
;moodE:
;    btfsc   mood,2
;    goto    moodm
;    goto    mood3
;    goto    loop
;    
;moodF:
;    btfsc   mood,2
;    goto    moodm
;    goto    mood1
;    goto    loop
;    //</editor-fold>
;
;//<editor-fold defaultstate="collapsed" desc="MODOS">
;mood0:
;    bcf	    PORTE,0
;    bcf	    PORTE,1
;    bcf	    PORTE,2
;    
;    clrf    dise+6
;    clrf    dise+7
;    goto    loop
;    
;mood1:
;    movf    Tsema1,W
;    movwf   var
;    bsf	    PORTE,0
;    bcf	    PORTE,1
;    bcf	    PORTE,2
;    
;    btfss   PORTB,1
;    call    inc
;    
;    btfss   PORTB,2
;    call    decr
;    
;    movf    var,W
;    movwf   Tsema1
;    movwf   PRUEBA
;    
;    
;    call divisor
;    
;    movf    UNI,W
;    movwf   UNI+4
;    
;    movf    DECE,W
;    movwf   DECE+4
;    
;    ;call    disp_mood_on
;    goto    loop
;mood2:
;    movf    Tsema2,W
;    movwf   var
;    bcf	    PORTE,0
;    bsf	    PORTE,1
;    bcf	    PORTE,2
;    
;    btfss   PORTB,1
;    call    inc
;    
;    btfss   PORTB,2
;    call    decr
;    
;    movf    var,W
;    movwf   Tsema2
;    movwf   PRUEBA
;    
;    
;    call    divisor
;    
;    movf    UNI,W
;    movwf   UNI+4
;    
;    movf    DECE,W
;    movwf   DECE+4
;    
;   ; call    disp_mood_on
;    goto    loop
;    
;mood3:
;    movf    Tsema3,W
;    movwf   var
;    bcf	    PORTE,0
;    bcf	    PORTE,1
;    bsf	    PORTE,2
;    
;    btfss   PORTB,1
;    call    inc
;    
;    btfss   PORTB,2
;    call    decr
;    
;    movf    var,W
;    movwf   Tsema3
;    movwf   PRUEBA
;    
;    
;    call divisor
;    
;    movf    UNI,W
;    movwf   UNI+4
;    
;    movf    DECE,W
;    movwf   DECE+4
;    
;   ; call    disp_mood_on
;    goto    loop
;    
;mood4:
;    bsf	    PORTE,0
;    bsf	    PORTE,1
;    bsf	    PORTE,2
;    
;    btfss   PORTB,1
;    call    acep
;    
;    btfss   PORTB,2
;    call    rech
;    
;    goto loop
;    
;    
;moodm:
;    clrf    mood
;    goto    loop
;    
;acep:
;    btfss   PORTB,1
;    goto    $-1
;    clrf    mood
;    
;    movf    Tsema1,W
;    movwf   CONT
;    
;    movf    Tsema2,W
;    movwf   CONT+1
;    
;    movf    Tsema3,W
;    movwf   CONT+2
;    goto    loop
;    
;rech:
;    btfss   PORTB,2
;    goto    $-1
;    clrf    mood
;    goto    loop
;    //</editor-fold>

   
  ;-------------------------sub rutinas-----------------------------------------

//<editor-fold defaultstate="collapsed" desc="DIVISOR">
divisor: 
    clrf	DECE	    ;limpuiar la variable donde se guardan las decenas	
    movlw	10	    ;mover 10 a w
    subwf	PRUEBA, W    ;restar 10 al valor del PORT A
    btfsc	STATUS, 0   ;skip if el carry esta en 0
    incf	DECE	    ; incrementar el contador de la variable decenas
    btfsc	STATUS, 0   ;skip if el carry esta en 0
    movwf	PRUEBA	    ; mover el valor de la resta a w
    btfsc	STATUS, 0   ;skip if el carry esta en 0
    goto	$-7	    ; si se puede seguir restando 10 entonces realizar todo el proceso
    call	unidades	    ; si ya no se puede restar 10, por que la bandera de carry se encendio entonces ir a unidades
    return
unidades:
    clrf	UNI	    ;limpiar la variable donde se guardan las unidades
    movlw	1	    ;mover 1 a w
    subwf	PRUEBA, F    ; restar 1 al valor del PORT A
    btfsc	STATUS, 0   ;skip if el carry esta en 0
    incf	UNI	    ; incrementar el contador de la variable unidades
    btfss	STATUS, 0   ; si tenemos un carry en el valor entonces realizar otra vez el proceso
    return		    ; si no se puede seguir restando 1 erntonces se regresa al stack 
    goto $-6
    //</editor-fold>
 
//<editor-fold defaultstate="collapsed" desc="IO PORTS">
io:
    banksel ANSEL 
    clrf    ANSEL 
    clrf    ANSELH
     
    banksel TRISA 
    clrf TRISA
    movlw 007h
    movwf TRISB
    clrf TRISC
    clrf TRISD
    clrf TRISE
    
 
    banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    clrf PORTE
    return
    //</editor-fold>
 
//<editor-fold defaultstate="collapsed" desc="TIMER0">
contimer:
    banksel TRISA
    bcf	    T0CS ;RELOJ interno
    bcf	    PSA	; PRESCALER, se asigna al timer0
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0; PS=111, velocidad de seleccion
    banksel PORTA
    reiniciarT0
    return
    //</editor-fold>
    
//<editor-fold defaultstate="collapsed" desc="TIMER1">
contimer1:
    banksel PORTA
    bsf	TMR1ON	    ; habilitamos el TMR1
    bcf TMR1CS	    
    bcf T1OSCEN
    bsf	T1CKPS0
    bsf	T1CKPS1
    bcf	TMR1GE
    
    banksel PORTA
    reiniciarT1
    return
    //</editor-fold>

//<editor-fold defaultstate="collapsed" desc="TIMER2">
contimer2:
    banksel PORTA  
    bsf	    T2CKPS1 ; en esta parte colocaremos el PreScaler a 1:8
    bsf	    T2CKPS0
    bsf	    TMR2ON  ; habilitaremos el TMR2
    bsf	    TOUTPS3 ; colocaremos el PostScaler a 1:16
    bsf	    TOUTPS2
    bsf	    TOUTPS1
    bsf	    TOUTPS0
    
    banksel TRISA
    reiniciarT2
    return
    //</editor-fold>

//<editor-fold defaultstate="collapsed" desc="CLOCK">
conclock:
    banksel OSCCON
    bcf	    IRCF0 ;el reloj oscilara a 1MHz
    bcf	    IRCF1 
    bsf	    IRCF2 
    bsf	    SCS	    ; habilitar reloj interno
    
    return
    //</editor-fold>

//<editor-fold defaultstate="collapsed" desc="CONFIGURACION INTERRUPCIONES">
coninten:
    ; en esta parte declararemos y colocaremos las banderas necesarias para cada Timer
    banksel PORTA
    bsf	    GIE	    ; INTCON	
    bsf	    PEIE
    
    bsf	    T0IE
    bcf	    T0IF
    ; colocamos las banderas de habilitar interrupcion
    
    banksel TRISA
    bsf	TMR1IE
    bsf TMR2IE
    ; limpiamos las banderas de interrupcion para crear nuestros ciclos
    banksel PORTA
    bcf TMR1IF
    bcf	TMR2IF
   
    return
    //</editor-fold>
  
;//<editor-fold defaultstate="collapsed" desc="DISPLAYS">
;dison2: 
;			    ; aqui se preparan los displays, quiere decir que se coloca el valor que corresponde a cada 1
;    movwf   UNI+1,W
;    call    tabla
;    movwf   dise
;    
;    movwf   DECE+1,W
;    call    tabla
;    movwf   dise+1
;    
;    movwf   UNI+2,W
;    call    tabla
;    movwf   dise+2
;    
;    movwf   DECE+2,W
;    call    tabla
;    movwf   dise+3
;    
;    movwf   UNI+3,W
;    call    tabla
;    movwf   dise+4
;    
;    movwf   DECE+3,W
;    call    tabla
;    movwf   dise+5
;    
;    movwf   UNI+4
;    call    tabla
;    movwf   dise+6
;    
;    movwf   DECE+4,W
;    call    tabla
;    movwf   dise+7
;    return
;    
;    //</editor-fold>
    
;//<editor-fold defaultstate="collapsed" desc="SEMAFORO">
;V1:
;    
;    call    VALSEMA
;    call    DISPSEMA
;    
;    bcf	    PORTB,0
;    bcf	    PORTA,0
;    bcf	    PORTA,7
;    bsf	    PORTA,2
;    bsf	    PORTA,3
;    bsf	    PORTA,6
;   
;    movlw    6
;    subwf    SEMA2,W
;   
;    btfsc    STATUS,2
;    call     V1P
;    return
;   
;V1P:
;    bcf	    CONT,0
;    bsf	    CONT,1
;    return
;    
;VI1:
;   
;    call    VALSEMA
;    call    DISPSEMA
;    
;    btfss   INTER,0
;    bcf	    PORTA,2
;    
;    btfsc   INTER,0
;    bsf	    PORTA,2
;    
;    movlw   3
;    subwf   SEMA2,W
;    
;    btfsc   STATUS,2
;    call    A1P
;    return
;    
;A1P:
;    bcf	    CONT,1
;    bsf	    CONT,2
;    return
;
;A1:
;    
;    call    VALSEMA
;    call    DISPSEMA
;    
;    bcf	    PORTA,2
;    bsf	    PORTA,1
;    
;    movf    TVIA+1,W
;    subwf   SEMA3,W
;    
;    btfsc   STATUS,2
;    call    V2P
;    return
;    
;V2P:
;    bcf	    CONT,2
;    bsf	    CONT,3
;    
;    movf    TVIA+1,W
;    movwf   SEMA2
;    
;    addwf   TVIA+2,W
;    movwf   SEMA1
;    return
;    
;V2:
;    call    VALSEMA
;    call    DISPSEMA
;    
;    bcf	    PORTA,1
;    bcf	    PORTA,3
;    bsf	    PORTA,0
;    bsf	    PORTA,5
;    
;    movlw   6
;    subwf   SEMA3,W
;    
;    btfsc   STATUS,2
;    call    PI2
;    return
;
;PI2:
;    bcf	    CONT,3
;    bsf	    CONT,4
;    return
;    
;VI2:	
;    call    VALSEMA
;    call    DISPSEMA
;    
;    btfss   INTER,0
;    bcf	    PORTA,5
;    
;    btfsc   INTER,0
;    bsf	    PORTA,5
;    
;    movlw   3
;    subwf   SEMA3,W
;    
;    btfsc   STATUS,2
;    call    A2P
;    return
;    
;A2P:
;    bcf	    CONT,4
;    bsf	    CONT,5
;    return
;
;A2:
;    call    VALSEMA
;    call    DISPSEMA
;    
;    bcf	    PORTA,5
;    bsf	    PORTA,4
;    
;    movf    TVIA+1,W
;    subwf   SEMA3,W
;    
;    btfsc   STATUS,2
;    call    V3P
;    return
;    
;V3P:
;    bcf	    CONT,5
;    bsf	    CONT,6
;    
;    movf    TVIA+1,W
;    movwf   SEMA2
;    
;    addwf   TVIA+2,W
;    movwf   SEMA1
;    return
;    
;V3:
;    call    VALSEMA
;    call    DISPSEMA
;    bcf	    PORTA,4
;    bcf	    PORTA,6
;    bsf	    PORTA,3
;    bsf	    PORTB,3
;    
;    movlw   6
;    subwf   SEMA3,W
;    
;    btfsc   STATUS,2
;    call    PI3
;    return
;
;PI3:
;    bcf	    CONT,6
;    bsf	    CONT,7
;    return
;    
;VI3:
;    call    VALSEMA
;    call    DISPSEMA
;    btfss   INTER,0
;    bcf	    PORTB,3
;    
;    btfsc   INTER,0
;    bsf	    PORTB,3
;    
;    movlw   3
;    subwf   SEMA3,W
;    
;    btfsc   STATUS,2
;    call    A3P
;    return
;    
;A3P:
;    bcf	    CONT,7
;    bsf	    CONT+1,0
;    return
;
;A3:
;    call    VALSEMA
;    call    DISPSEMA
;    bcf	    PORTB,3
;    bsf	    PORTA,7
;    
;    movf    TVIA,W
;    subwf   SEMA2,W
;    
;    btfsc   STATUS,2
;    call    V4P
;    return
;    
;V4P:
;    bcf	    CONT+1,0
;    bsf	    CONT,0
;    
;    movf    TVIA,W
;    movwf   SEMA1
;    
;    addwf   TVIA+1,W
;    movwf   SEMA3
;    return
;    //</editor-fold>

//<editor-fold defaultstate="collapsed" desc="VALORES">
VALSEMA:
    movf    SEMA1,W
    movwf   PRUEBA
    call    divisor
    movf    UNI,W
    movwf   UNI+1
    movf    DECE,W
    movwf   DECE+1
    
    movf    SEMA2,W
    movwf   PRUEBA
    call    divisor
    movf    UNI,W
    movwf   UNI+2
    movf    DECE,W
    movwf   DECE+2
    
    movf    SEMA3,W
    movwf   PRUEBA
    call    divisor
    movf    UNI,W
    movwf   UNI+3
    movf    DECE,W
    movwf   DECE+3
    
    return
    //</editor-fold>

//<editor-fold defaultstate="collapsed" desc="Display semaforo ">
DISPSEMA:
    movwf   UNI+2,W
    call    tabla
    movwf   dise+2
    
    movwf   DECE+2,W
    call    tabla
    movwf   dise+3
    
    movwf   UNI+3,W
    call    tabla
    movwf   dise+4
    
    movwf   DECE+3,W
    call    tabla
    movwf   dise+5
    
    movwf   UNI+1,W
    call    tabla
    movwf   dise
    
    movwf   DECE+1,W
    call    tabla
    movwf   dise+1
    return
    //</editor-fold>

;//<editor-fold defaultstate="collapsed" desc="Displays de modos">
;DISPMOOD:
;    movwf   UNI+4,W
;    call    tabla
;    movwf   dise+6
;    
;    movwf   DECE+4,W
;    call    tabla
;    movwf   dise+7
;    return
;    //</editor-fold>


end






