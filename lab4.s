; Section 9 - SWI Operations for Other Plug-Ins: the Embest Board Plug-In starts on page 26
; Review Table 5 - SWI operations as currently used for the Embest board Plug-In
; Review Section 9.1 - Details and Examples for SWI Codes for the Embest Board Plug-in
; Make sure to enable EmbestBoardPlugin and SWIInstructions plugins from Preferences menu
; Make sure to enable PluginsUI from the View menu

; The .equ directive is used to set up aliases for specific values
; Figure 16, 8-segment display aliases
.equ SEG_A,0x80
.equ SEG_B,0x40 
.equ SEG_C,0x20 
.equ SEG_D,0x08 
.equ SEG_E,0x04 
.equ SEG_F,0x02 
.equ SEG_G,0x01 
.equ SEG_P,0x10

; Subset of 8-segment display alphanumeric aliases
; The bitwise OR command allows you to light up multiple segments at a time
.equ SIX, SEG_A|SEG_G|SEG_F|SEG_E|SEG_D|SEG_C
.equ F, SEG_A|SEG_G|SEG_F|SEG_E

; The Opcode to light up the 8-segment display is 0x200
; According to Table 5, r0 must be set before the operation is performed

; Any 1 in the lowest 8 bits of r0 will result in the corresponding segment lighting up
; Figure 15 shows which segments correspond to which values

mov r0,#0x20 ; 0010 0000
swi 0x200 ; light up 8-segment display

mov r0,#0x02 ; 0000 0010
swi 0x200

mov r0,#SIX ; 1010 1111
swi 0x200

mov r0,#F ; 1000 0111
swi 0x200

; The Opcode to print a string on the LCD display is 0x204
; According to Table 5, r0, r1, and r2 must be set before the operation is performed

; r0 should be set to the horizontal position (x-coordinate)
; r1 should be set to the vertical position (y-coordinate)
; r2 should be set to the location of a string in memory
mov r0,#5
mov r1,#3
ldr r2,=myString

swi 0x204 ; this will print "twenty-seven" starting at row 3, column 5

; The Opcode to print an integer on the LCD display is 0x205
; According to Table 5, r0, r1, and r2 must be set before the operation is performed

; r0 should be set to the horizontal position (x-coordinate)
; r1 should be set to the vertical position (y-coordinate)
; r2 should be set to the decimal value to be printed
mov r0,#5
mov r1,#2
mov r2,#27

swi 0x205 ; this will print "27" starting at row 2, column 5


; The Opcode to light up the red LEDs is 0x201
; According to Table 5, r0 must be set before the operation is performed

; Any 1 in the lowest 2 bits of r0 will result in the corresponding LED lighting up
mov r0,#0x01
swi 0x201 ; this will light up the left LED

mov r0,#0x02
swi 0x201 ; this will light up the right LED

mov r0,#0x03
swi 0x201 ; this will light up both LEDs

Loop:

; The Opcode to check if either of the black buttons is pressed is 0x202
; According to Table 5, r0 will have its value set after the operation is performed

swi 0x202

cmp r0,#0x01 ; check for left button
moveq r1,#0x4C ; 'L'
cmp r0,#0x02 ; check for right button
moveq r1,#0x52 ; 'R'

; The Opcode to check if any of the blue buttons is pressed is 0x203
; According to Table 5, r0 will have its value set after the operation is performed
; Note that Figure 19 labels the buttons differently than the actual UI in ARMSim#

swi 0x203

; If we want to check 2,3 which is the 12th button, we should use the value 0000 1000 0000 0000 or 0800
cmp r0,#0x0800
beq Done ; exit loop if 2,3 is pressed

BAL Loop
Done:

swi 0x11

myString: .asciz "twenty-seven"