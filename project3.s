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
swi CLEAR_LCD
bcs ERR_DEF
mov r0,#0
mov r1,#0
mov r2,#0
swi LCD_INT
bcs ERR_DEF

;resets r0, checks r0 for black flag, then blue flag. loops otherwise
;cmn is to clear carry bit set by bne to ensure bcs works properly
CHECK_BUTTONS:
mov r0, #0

swi CHECK_BLACK
bcs ERR_CHECK
cmp r0,#0
bne BLACK_PRESSED
cmn r0,#0

swi CHECK_BLUE
;bcs ERR_CHECK
cmp r0,#0
bne BLUE_PRESSED
cmn r0,#0

bal CHECK_BUTTONS

;clear carry, reset 8-seg, clear LCD, then reset LCD
BLACK_PRESSED:
cmn r0,#0
;default 8_segment state
mov r0,#0x00
swi EIGHT_SEG
bcs ERR_BLACK
;default LCD state
swi CLEAR_LCD
bcs ERR_BLACK
mov r3, #0
mov r2, #0
mov r1, #0
swi LCD_INT
bcs ERR_BLACK
bal CHECK_BUTTONS

;clears carry from bne
;copies blue button val to r3 for cmp
;sets r1 for LCD print
BLUE_PRESSED:
cmn r0,#0
mov r3,r0
mov r1, #0

;one section for each blue button
;if value not equal to button, branches to next button check
;if equal, clears carry, sets r0 to segment value, prints segment
;sets r0 to 0 for x coordinate, sets r1 for y
;adds latest blue button to current lcd then clears lcd to get rid of old value
;prints out the new lcd value then branches back to check button loop
;
seven:
cmp r3,#0x01
bne eight
cmn r0,#0
mov r0,#SEVEN
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #7
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

eight:
cmp r3,#0x02
bne nine
cmn r0,#0
mov r0,#EIGHT
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #8
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

nine:
cmp r3,#0x04
bne four
cmn r0,#0
mov r0,#NINE
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #9
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

four:
cmp r3,#0x10
bne five
cmn r0,#0
mov r0,#FOUR
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #4
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

five:
cmp r3,#0x20
bne six
cmn r0,#0
mov r0,#FIVE
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #5
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

six:
cmp r3,#0x40
bne one
cmn r0,#0
mov r0,#SIX
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #6
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

one:
cmp r3,#0x100
bne two
cmn r0,#0
mov r0,#ONE
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #1
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

two:
cmp r3,#0x200
bne three
cmn r0,#0
mov r0,#TWO
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #2
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

three:
cmp r3,#0x400
bne zero
cmn r0,#0
mov r0,#THREE
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #3
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

zero:
cmp r3,#0x2000
bne unassigned
cmn r0,#0
mov r0,#ZERO
swi EIGHT_SEG
bcs ERR_BLUE
mov r0,#0
add r2, r2, #0
swi CLEAR_LCD
bcs ERR_BLUE
swi LCD_INT
bcs ERR_BLUE
b CHECK_BUTTONS

unassigned:
mov r0, #E
swi EIGHT_SEG
bcs ERR_BLUE
bal CHECK_BUTTONS

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

err_def: .asciz "Error, default malfunction"
err_check: .asciz "Error, checkbutton malfunction"
err_black: .asciz "Error, black button malfunction"
err_blue: .asciz "Error, blue button malfunction"
