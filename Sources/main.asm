;*******************************************************************
;* This stationery serves as the framework for a user application. *
;* For a more comprehensive program that demonstrates the more     *
;* advanced functionality of this processor, please see the        *
;* demonstration applications, located in the examples             *
;* subdirectory of the "Freescale CodeWarrior for HC08" program    *
;* directory.                                                      *
;*******************************************************************

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
            
;
; export symbols
;
            XDEF _Startup
            ABSENTRY _Startup

;
; variable/data section
;
            ORG    RAMStart         ; Insert your data definition here          
;
; code section
;
            ORG    ROMStart
            TABLESTART:  DC.B $38,$38,$38,$38,$0F,$06,$01,$00

_Startup:
            LDA #$12
            STA SOPT1
            LDHX   #RAMEnd+1        ; initialize the stack pointer
            TXS
            CLI			; enable interrupts
            JSR ENTYSAL ;iniciar puertos
            JSR INICIOCRONOMETRO
			
INSTRUCCIONES:
            JSR INICIO ;Subrutina de inicio pantalla
            JSR INSTRUCPANTALLA ;salta hacia introducir datos
            JSR INICIOCRONOMETRO ;salta hacia las instrucciones del cronometro
FINIQUITI:  BRA FINIQUITI 
            	
INICIO: 	LDHX #TABLESTART ;enciende la pantalla
REGRESATE:	LDA 0,X ;ubicar la localidad de la memoria en 0
			BEQ FINISH ;brinca a su regreso si se ubicaron los valores (z=1)
        	JSR COMANDOS ;subrutina para ejecutar la accion
			AIX #$01 ;se agrega al registro un valor 01.
			BRA REGRESATE ;se devuelve a la misma subrutina
FINISH:     RTS	

INSTRUCPANTALLA:
            LDA #$53 ; Escribe una S
            JSR DATOS ;Comando para ejecutar la palabra
            LDA #$65  ; Escribe una e
            JSR DATOS ; Comando para ejecutar la palabra
            LDA #$67  ; Escribe una g
            JSR DATOS ; Comando para ejecutar la palabra 
            LDA #$75  ; Escribe una u 
            JSR DATOS ; Comando para ejecutar la palabra 
            LDA #$6E  ; Escribe una n
            JSR DATOS ; Comando para ejecutar la palabra
            LDA #$64  ; Escribe una d
            JSR DATOS ; Comando para ejecutar la palabra
            LDA #$65  ; Escribe una e
            JSR DATOS ; Comando para ejecutar la palabra
            LDA #$72  ; Escribe una r
            JSR DATOS ; Comando para ejecutar la palabra
            LDA #$6F  ; Escribe una o
            JSR DATOS ; Comando para ejecutar la palabra
            LDA #$3A  ; Escribe dos puntos
            JSR DATOS ; Comando para ejecutar la palabra 
            LDA #$20  ; Escribe un espacio
            JSR DATOS ; Comando para ejecutar la palabra           
            LDA #$30  ; Escribe un 0
            JSR DATOS ; Comando para ejecutar la palabra 
            LDA #$30  ; Escribe un 0
            JSR DATOS ; Comando para ejecutar la palabra 
            LDA #$2E  ; Escribe un punto
            JSR DATOS ; Comando para ejecutar la palabra 
            RTS

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*CRONOMETRO COMANDOS=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
INICIOCRONOMETRO:		
			LDA #$30 ;cargar el reset
			STA $60  ;guardarlo en el espacio de decenas
            LDA #$30 ;cargar el reset
            STA $61  ;guardarlo en el espacio de unidades 
            
            LDA #$8C ;Se ubica en la posicion en la pantalla
            JSR COMANDOS ;subrutina para ejecutar la accion
            LDA $61 ;carga la memoria de las decenas
            JSR DATOS ; Comando para ejecutar la palabra ya que si no se cargara lo pasado en la pantalla
            LDA #$8B ;Se ubica en la posicion en la pantalla
            JSR COMANDOS ;subrutina para ejecutar la accion
            LDA $60 ;carga la memoria de las decenas
            JSR DATOS ; Comando para ejecutar la palabra ya que si no se cargara lo pasado en la pantalla
            
            JSR MENU ;brincar hacia el menu
            
MENU:		BRCLR 2, PTAD, UNIDADES ;brinca hacia aumento de unidades si se pulsa el SW1
            BRCLR 3, PTAD, INICIOCRONOMETRO ; Va hacia el empiezo para reiniciar la cuenta y que pare
			BRA MENU ;Entra en loop hasta que se confirme el boton

UNIDADES:	BRCLR 3, PTAD, INICIOCRONOMETRO ; Va hacia el empiezo para reiniciar la cuenta y que pare
			INC $61 ;incrementa las unidades
			LDA #$8C ;Se ubica en la posicion en la pantalla
            JSR COMANDOS ;subrutina para ejecutar la accion
            LDA $61 ;carga la memoria de las decenas
            JSR DATOS ; Comando para ejecutar la palabra 
			LDA $61 ;carga la memoria localizada en la 61 (unidades)
            CMP #$39 ;compara con un numero 09 a ver si se llego a ese numero en la memoria 61
            BEQ DECENAS ;salta si es igual a la comparacion (z=1) para sumar 1 decena
            BRA UNIDADES ;si no, va de nuevo a agregar un valor a unidades	
            
DECENAS:	BRCLR 3, PTAD, INICIOCRONOMETRO ; Va hacia el empiezo para reiniciar la cuenta y que pare
         	LDA #$2F  ;carga un reset con el anterior caracter del 0 en hexa, ya que en las unidades se van a incrementar esto
         	STA $61   ; lo agrega a los segundos para finalizar el 09
         	INC $60  ; aumenta las decenas en 1
         	LDA #$8B ;Se ubica en la posicion en la pantalla
            JSR COMANDOS ;subrutina para ejecutar la accion
         	LDA $60 ;carga las decenas
         	JSR DATOS ; Comando para ejecutar la palabra
         	LDA $60  ;carga las decenas
         	CMP #$36 ;comprueba si se cumplio el minuto
         	BEQ INICIOCRONOMETRO ;si es asi empieza de nuevo el programa
         	BRA UNIDADES ;si no, sigue contando
            
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*INICIALIZAR PUERTOS=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

ENTYSAL:    LDA #$FF
            STA PTBDD ;Declarar B como salida
            LDA $00
            STA PTBD ; limpiar datos en PTBD
            BSET 0,PTADD ;El pin 0 sera puerto A que indicara la salida RS 15
            BSET 1,PTADD ;El PIN 1 sera puerto A que indicara la salida ENABLE 25
            BCLR 2,PTADD ;limpiar SW1 
            BCLR 3,PTADD ;limpiar SW2   
            RTS
             
 ;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*CODIGO PARA PANTALLA=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
COMANDOS:
            BCLR 0, PTAD
            STA PTBD
            JSR ENABLE
            RTS
           
ENABLE:  
            BSET 1, PTAD
            JSR RETARDO_RTI
            BCLR 1, PTAD
            RTS
            
DATOS:   
            BSET 0, PTAD
            STA PTBD
            JSR ENABLE
            RTS 
         
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

;**************************************************************
;* 					RETARDO RTI 				              *
;*             1 segundo de retraso                           *
;**************************************************************

RETARDO_RTI:  
		LDA #$06 ;Cargamos un 6 que indicara que sera un segundo de tiempo en el retardo
		STA SRTISC	;Lo guardamos este lugar para la interrupcion SRTISC
CICLO:	LDA SRTISC ;Cargamos el SRTISC
		CMP #$86	;comparamos con lo que este registrado en nuestra memoria que sera la que marque la bandera de SRTISC
		BNE CICLO ;se pone en bucle aqui hasta que sean iguales (z=0)
		LDA #$40 ;se carga un 40 hexadecimal
		STA SRTISC ;y se cuarda en la locacion 60 de SRTISC
		RTS		        
             
             
;**************************************************************
;* spurious - Spurious Interrupt Service Routine.             *
;*             (unwanted interrupt)                           *
;**************************************************************              
spurious:				; placed here so that security value
			NOP			; does not change all the time.
			RTI

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************

            ORG	$FFFA

			DC.W  spurious			;
			DC.W  spurious			; SWI
			DC.W  _Startup			; Reset
