; 8-segment display aliases
.equ TOP,0x80
.equ TOP_RIGHT,0x40 
.equ BOTTOM_RIGHT,0x20 
.equ BOTTOM,0x08 
.equ BOTTOM_LEFT,0x04 
.equ MIDDLE,0x02 
.equ TOP_LEFT,0x01 
.equ PERIOD,0x10

; 8-segment numbers display aliases
.equ ZERO, TOP|TOP_LEFT|TOP_RIGHT|BOTTOM_LEFT|BOTTOM_RIGHT|BOTTOM
.equ ONE, TOP_RIGHT|BOTTOM_RIGHT
.equ TWO, TOP|TOP_RIGHT|MIDDLE|BOTTOM_LEFT|BOTTOM
.equ THREE, TOP|TOP_RIGHT|MIDDLE|BOTTOM_RIGHT|BOTTOM
.equ FOUR, TOP_LEFT|TOP_RIGHT|MIDDLE|BOTTOM_RIGHT
.equ FIVE, TOP|TOP_LEFT|MIDDLE|BOTTOM_RIGHT|BOTTOM
.equ SIX, TOP|TOP_LEFT|MIDDLE|BOTTOM_LEFT|BOTTOM|BOTTOM_RIGHT
.equ SEVEN, TOP|TOP_RIGHT|BOTTOM_RIGHT
.equ EIGHT, TOP|TOP_LEFT|TOP_RIGHT|MIDDLE|BOTTOM_LEFT|BOTTOM_RIGHT|BOTTOM
.equ NINE, TOP|TOP_LEFT|TOP_RIGHT|MIDDLE|BOTTOM_RIGHT|BOTTOM
.equ E, TOP|TOP_LEFT|MIDDLE|BOTTOM_LEFT|BOTTOM

; swi commands for the various buttons
.equ EIGHT_SEG, 0x200
.equ LED, 0x201
.equ CHECK_BLACK, 0x202
.equ CHECK_BLUE, 0x203
.equ LCD_STRING, 0x204
.equ LCD_INT, 0x205
.equ CLEAR_LCD, 0x206
.equ PRINT_STRING, 0x02
.equ EXIT, 0x11

;default 8_segment state
mov r0,#0x00
swi EIGHT_SEG
bcs ERR_DEF

;default LCD state
DEFAULT:
cmn r0,#0
swi CLEAR_LCD
bcs ERR_DEF
mov r0,#0
mov r1,#0
mov r2,#0
swi LCD_INT
bcs ERR_DEF
mov r0,#1
mov r1,#0
ldr r2,=currentLCD
swi LCD_STRING
bcs ERR_DEF
mov r0,#0
mov r1,#2
ldr r2,=defaultButton
swi LCD_STRING
bcs ERR_DEF
KEYPAD:
mov r0,#0
mov r1,#4
ldr r2,=defaultKeypad1
swi LCD_STRING
bcs ERR_DEF
mov r0,#0
mov r1,#6
ldr r2,=defaultKeypad2
swi LCD_STRING
bcs ERR_DEF
mov r0,#0
mov r1,#8
ldr r2,=defaultKeypad3
swi LCD_STRING
bcs ERR_DEF
mov r2, #0

;resets r0, checks r0 for black flag, then blue flag. loops otherwise
;cmn is to clear carry bit set by bne to ensure bcs works properly
CHECK_BUTTONS:
mov r0,#0

swi CHECK_BLACK
bcs ERR_CHECK
cmp r0,#0
bne BLACK_PRESSED
cmn r0,#0

swi CHECK_BLUE
bcs ERR_CHECK
cmp r0,#0
bne BLUE_PRESSED
cmn r0,#0

bal CHECK_BUTTONS

;clear carry, reset 8-seg, clear LCD, then reset LCD
BLACK_PRESSED:
cmn r0,#0
mov r0, #10
mov r1, #2
ldr r2, =resetLCD
swi LCD_STRING
bcs ERR_BLACK
bal DEFAULT


;clears carry from bne
;copies blue button val to r3 for cmp
;sets r1 for LCD print
BLUE_PRESSED:
cmn r0,#0
mov r1, #0
add r3,r3,r0

cmp r0,#0x01
beq seven
cmp r0,#0x02
beq eight
cmp r0,#0x04
beq nine
cmp r0,#0x10
beq four
cmp r0,#0x20
beq five
cmp r0,#0x40
beq six
cmp r0,#0x100
beq one
cmp r0,#0x200
beq two
cmp r0,#0x400
beq three
cmp r0,#0x2000
beq zero
bal unassigned

;one section for each blue button
;if value not equal to button, branches to next button check
;if equal, clears carry, sets r0 to segment value, prints segment
;sets r0 to 0 for x coordinate, sets r1 for y
;adds latest blue button to current lcd then clears lcd to get rid of old value
;prints out the new lcd value then branches back to check button loop
;
seven:
mov r0,#SEVEN
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

eight:
mov r0,#EIGHT
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

nine:
mov r0,#NINE
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

four:
mov r0,#FOUR
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

five:
mov r0,#FIVE
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

six:
mov r0,#SIX
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

one:
mov r0,#ONE
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

two:
mov r0,#TWO
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

three:
mov r0,#THREE
swi EIGHT_SEG
bcs ERR_BLUE
bal BLUE_LCD

zero:
mov r0,#ZERO
swi EIGHT_SEG
bcs ERR_BLUE
b CHECK_BUTTONS

;if using bne: carry bit is not reset for last two blue buttons because their values are higher than 0x2000
unassigned:
mov r0, #E
swi EIGHT_SEG
bcs ERR_BLUE
bal CHECK_BUTTONS

BLUE_LCD:
swi CLEAR_LCD
bcs ERR_BLUE
mov r0,#0
mov r2,r3
swi LCD_INT
bcs ERR_BLUE
b KEYPAD


;if any swi commands fail, branch to various errors for each section
;default state/startup section
ERR_DEF:
ldr r0, =err_def
swi PRINT_STRING
b DONE

;check button section
ERR_CHECK:
ldr r0, =err_check
swi PRINT_STRING
b DONE

;black button section
ERR_BLACK:
ldr r0, =err_black
swi PRINT_STRING
b DONE

;blue button section
ERR_BLUE:
ldr r0, =err_blue
swi PRINT_STRING
b DONE

DONE:
swi EXIT

currentLCD: .asciz " is your current total."
defaultButton: .asciz "You haven't pressed a button yet!"
buttonPressed0: .asciz "The button you pressed is 0"
buttonPressed1: .asciz "The button you pressed is 1"
buttonPressed2: .asciz "The button you pressed is 2"
buttonPressed3: .asciz "The button you pressed is 3"
buttonPressed4: .asciz "The button you pressed is 4"
buttonPressed5: .asciz "The button you pressed is 5"
buttonPressed6: .asciz "The button you pressed is 6"
buttonPressed7: .asciz "The button you pressed is 7"
buttonPressed8: .asciz "The button you pressed is 8"
buttonPressed9: .asciz "The button you pressed is 9"
defaultKeypad1: .asciz "7 8 9 E"
defaultKeypad2: .asciz "4 5 6 E"
defaultKeypad3: .asciz "E 0 E E"
resetLCD: .asciz "System reset!"
NALCD: .asciz "Error, unassigned button pressed"
err_def: .asciz "Error, default malfunction"
err_check: .asciz "Error, checkbutton malfunction"
err_black: .asciz "Error, black button malfunction"
err_blue: .asciz "Error, blue button malfunction"
