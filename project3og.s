; The .equ directive is used to set up aliases for specific values
; Figure 16, 8-segment display aliases
.equ TOP,0x80
.equ TOP_RIGHT,0x40 
.equ BOTTOM_RIGHT,0x20 
.equ BOTTOM,0x08 
.equ BOTTOM_LEFT,0x04 
.equ MIDDLE,0x02 
.equ TOP_LEFT,0x01 
.equ PERIOD,0x10

; 8-segment numbers
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

; values to light up the various red LEDs, left and right also work for black buttons
.equ LEFT_LED, 0x01
.equ RIGHT_LED, 0x02
.equ BOTH_LED, 0x03

;setting up register for Blue check later on
mov r4, #17
;setting up register for LCD value later on
mov r5, #0

;default 8_segment state
mov r0,0x00
swi EIGHT_SEG

;default LCD state
mov r0,#0
mov r1,#0
mov r2,#0
swi LCD_INT

CHECK_BUTTONS:
mov r0, r4

swi CHECK_BLACK
cmp r0,r4
bne BLACK_PRESSED

swi CHECK_BLUE
cmp r0,r4
bne BLUE_PRESSED

b CHECKBUTTONS

BLACK_PRESSED:
;default 8_segment state
mov r0,0x00
swi EIGHT_SEG

;default LCD state
mov r0,#0
mov r1,#0
mov r2,#0
swi LCD_INT

b CHECK_BUTTONS

BLUE_PRESSED:
;check blue for actual value for LCD
cmp r0, #1
add r5,r0,r5









;checkBlue:
;swi CHECK_BLUE
;cmp r0,r4
;beq BLUE_PRESSED
;cmp r4,#15
;addlt r4,r4,#1
;ble checkBlue
;mov r4,#1
;b checkButtons

;swi CHECK_BLUE
;cmp r0, #16
;blt BLUE_PRESSED
