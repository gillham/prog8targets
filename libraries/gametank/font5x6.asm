        .align $100  ; page alignment
MYFONT2:
; 0-15
; char 0
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;
; char 1
.byte %00000
.byte %00000
.byte %00111
.byte %00100
.byte %00100
.byte %00100 ; upper left
; char 2
.byte %00000
.byte %00000
.byte %11100
.byte %00100
.byte %00100
.byte %00100 ; upper right
; char 3
.byte %00100
.byte %00100
.byte %00111
.byte %00000
.byte %00000
.byte %00000 ; lower left
; char 4
.byte %00100
.byte %00100
.byte %11100
.byte %00000
.byte %00000
.byte %00000 ; lower right
; char 5
.byte %00000
.byte %00000
.byte %11111
.byte %00000
.byte %00000
.byte %00000 ; upper line
; char 6
.byte %00000
.byte %00000
.byte %11111
.byte %00000
.byte %00000
.byte %00000 ; lower line
; char 7
.byte %00100
.byte %00100
.byte %00100
.byte %00100
.byte %00100
.byte %00100 ; left line
; char 8
.byte %00100
.byte %00100
.byte %00100
.byte %00100
.byte %00100
.byte %00100 ; right line
; char 9
.byte %00000
.byte %01110
.byte %01110
.byte %01110
.byte %01110
.byte %00000 ; covered
; char 10
.byte %00001
.byte %00001
.byte %00001
.byte %00001
.byte %00001
.byte %00001 ; 1 pixel on right
; char 11
.byte %01000
.byte %01110
.byte %01100
.byte %01000
.byte %01000
.byte %00000 ; flag
; char 12
.byte %01110
.byte %11101
.byte %11111
.byte %01110
.byte %00100
.byte %01110 ; bomb
; char 13 option
.byte %11011
.byte %10001
.byte %00000
.byte %00000
.byte %10001
.byte %11011 ; corner pixels
; character 14 (left checkerboard)
.byte %10101
.byte %01010
.byte %10101
.byte %01010
.byte %10101
.byte %01010 ; left checkerboard thing
; character 15 (right checkerboard)
.byte %01010
.byte %10101
.byte %01010
.byte %10101
.byte %01010
.byte %10101 ; right checkerboard thing
; 16-31
; char 16
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;
; char 17
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ;

; 32-47
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ; space

.byte %00100
.byte %00100
.byte %00100
.byte %00000
.byte %00100
.byte %00000 ; !

.byte %01010
.byte %01010
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ; "

.byte %10100
.byte %11110
.byte %10100
.byte %11110
.byte %10100
.byte %00000 ; #

.byte %01110
.byte %10100
.byte %01100
.byte %01010
.byte %11100
.byte %00000 ; $

.byte %11000
.byte %00010
.byte %01100
.byte %10000
.byte %00110
.byte %00000 ; %

.byte %01000
.byte %10100
.byte %01000
.byte %10100
.byte %01010
.byte %00000 ; &

.byte %00100
.byte %00100
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ; '

.byte %00100
.byte %01000
.byte %01000
.byte %01000
.byte %00100
.byte %00000 ; (

.byte %00100
.byte %00010
.byte %00010
.byte %00010
.byte %00100
.byte %00000 ; )

.byte %10010
.byte %01100
.byte %11110
.byte %01100
.byte %10010
.byte %00000 ; *

.byte %00000
.byte %00100
.byte %01110
.byte %00100
.byte %00000
.byte %00000 ; +

.byte %00000
.byte %00000
.byte %00000
.byte %01000
.byte %10000
.byte %00000 ; ,

.byte %00000
.byte %00000
.byte %01110
.byte %00000
.byte %00000
.byte %00000 ; -

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %01000
.byte %00000 ; .

.byte %00010
.byte %00010
.byte %00100
.byte %01000
.byte %01000
.byte %00000 ; /

; 48-63
.byte %01100
.byte %10110
.byte %11010
.byte %10010
.byte %01100
.byte %00000 ; 0

.byte %00100
.byte %01100
.byte %00100
.byte %00100
.byte %00100
.byte %00000 ; 1

.byte %01100
.byte %10010
.byte %00100
.byte %01000
.byte %11110
.byte %00000 ; 2

.byte %11100
.byte %00010
.byte %01100
.byte %00010
.byte %11100
.byte %00000 ; 3

.byte %10010
.byte %10010
.byte %11110
.byte %00010
.byte %00010
.byte %00000 ; 4

.byte %11110
.byte %10000
.byte %11100
.byte %00010
.byte %11100
.byte %00000 ; 5

.byte %01100
.byte %10000
.byte %11100
.byte %10010
.byte %01100
.byte %00000 ; 6

.byte %11110
.byte %00010
.byte %00100
.byte %00100
.byte %00100
.byte %00000 ; 7

.byte %01100
.byte %10010
.byte %01100
.byte %10010
.byte %01100
.byte %00000 ; 8

.byte %01100
.byte %10010
.byte %01110
.byte %00010
.byte %01100
.byte %00000 ; 9

.byte %00000
.byte %00100
.byte %00000
.byte %00100
.byte %00000
.byte %00000 ; :

.byte %00000
.byte %00100
.byte %00000
.byte %00100
.byte %01000
.byte %00000 ; ;

.byte %00100
.byte %01000
.byte %10000
.byte %01000
.byte %00100
.byte %00000 ; <

.byte %00000
.byte %01110
.byte %00000
.byte %01110
.byte %00000
.byte %00000 ; =

.byte %01000
.byte %00100
.byte %00010
.byte %00100
.byte %01000
.byte %00000 ; >

.byte %11000
.byte %00100
.byte %01000
.byte %00000
.byte %01000
.byte %00000 ; ?

; 64-79
.byte %01100
.byte %10010
.byte %10110
.byte %10000
.byte %01110
.byte %00000 ; @

.byte %01100 ; A
.byte %10010 ; A
.byte %11110 ; A
.byte %10010 ; A
.byte %10010 ; A
.byte %00000 ; A

.byte %11100
.byte %10010
.byte %11100
.byte %10010
.byte %11100
.byte %00000 ; B

.byte %01100
.byte %10010
.byte %10000
.byte %10010
.byte %01100
.byte %00000 ; C

.byte %11100
.byte %10010
.byte %10010
.byte %10010
.byte %11100
.byte %00000 ; D

.byte %11110
.byte %10000
.byte %11100
.byte %10000
.byte %11110
.byte %00000 ; E

.byte %11110
.byte %10000
.byte %11100
.byte %10000
.byte %10000
.byte %00000 ; F

.byte %01100
.byte %10000
.byte %10110
.byte %10010
.byte %01100
.byte %00000 ; G

.byte %10010
.byte %10010
.byte %11110
.byte %10010
.byte %10010
.byte %00000 ; H

.byte %11100
.byte %01000
.byte %01000
.byte %01000
.byte %11100
.byte %00000 ; I

.byte %00010
.byte %00010
.byte %00010
.byte %10010
.byte %01100
.byte %00000 ; J

.byte %10010
.byte %10100
.byte %11000
.byte %10100
.byte %10010
.byte %00000 ; K

.byte %10000
.byte %10000
.byte %10000
.byte %10000
.byte %11110
.byte %00000 ; L

.byte %10010
.byte %11110
.byte %10010
.byte %10010
.byte %10010
.byte %00000 ; M

.byte %10010
.byte %11010
.byte %10110
.byte %10010
.byte %10010
.byte %00000 ; N

.byte %01100
.byte %10010
.byte %10010
.byte %10010
.byte %01100
.byte %00000 ; O

; 80-95
.byte %11100
.byte %10010
.byte %11100
.byte %10000
.byte %10000
.byte %00000 ; P

.byte %01100
.byte %10010
.byte %10010
.byte %10110
.byte %01110
.byte %00000 ; Q

.byte %11100
.byte %10010
.byte %11100
.byte %10100
.byte %10010
.byte %00000 ; R

.byte %01110
.byte %10000
.byte %01100
.byte %00010
.byte %11100
.byte %00000 ; S

.byte %11100
.byte %01000
.byte %01000
.byte %01000
.byte %01000
.byte %00000 ; T

.byte %10010
.byte %10010
.byte %10010
.byte %10010
.byte %01100
.byte %00000 ; U

.byte %10100
.byte %10100
.byte %10100
.byte %10100
.byte %01000
.byte %00000 ; V

.byte %10010
.byte %10010
.byte %10010
.byte %11110
.byte %10010
.byte %00000 ; W

.byte %10010
.byte %10010
.byte %01100
.byte %10010
.byte %10010
.byte %00000 ; X

.byte %10100
.byte %10100
.byte %01000
.byte %01000
.byte %01000
.byte %00000 ; Y

.byte %11110
.byte %00010
.byte %01100
.byte %10000
.byte %11110
.byte %00000 ; Z

.byte %01100
.byte %01000
.byte %01000
.byte %01000
.byte %01100
.byte %00000 ; [

.byte %10000
.byte %10000
.byte %01000
.byte %00100
.byte %00100
.byte %00000 ; \

.byte %01100
.byte %00100
.byte %00100
.byte %00100
.byte %01100
.byte %00000 ; ]

.byte %01000
.byte %10100
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ; ^

.byte %00000
.byte %00000
.byte %00000
.byte %00000
.byte %11110
.byte %00000 ; _

; 96-111
.byte %01000
.byte %00100
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ; `

.byte %01100 ; A
.byte %10010 ; A
.byte %11110 ; A
.byte %10010 ; A
.byte %10010 ; A
.byte %00000 ; A

.byte %11100
.byte %10010
.byte %11100
.byte %10010
.byte %11100
.byte %00000 ; B

.byte %01100
.byte %10010
.byte %10000
.byte %10010
.byte %01100
.byte %00000 ; C

.byte %11100
.byte %10010
.byte %10010
.byte %10010
.byte %11100
.byte %00000 ; D

.byte %11110
.byte %10000
.byte %11100
.byte %10000
.byte %11110
.byte %00000 ; E

.byte %11110
.byte %10000
.byte %11100
.byte %10000
.byte %10000
.byte %00000 ; F

.byte %01100
.byte %10000
.byte %10110
.byte %10010
.byte %01100
.byte %00000 ; G

.byte %10010
.byte %10010
.byte %11110
.byte %10010
.byte %10010
.byte %00000 ; H

.byte %11100
.byte %01000
.byte %01000
.byte %01000
.byte %11100
.byte %00000 ; I

.byte %00010
.byte %00010
.byte %00010
.byte %10010
.byte %01100
.byte %00000 ; J

.byte %10010
.byte %10100
.byte %11000
.byte %10100
.byte %10010
.byte %00000 ; K

.byte %10000
.byte %10000
.byte %10000
.byte %10000
.byte %11110
.byte %00000 ; L

.byte %10010
.byte %11110
.byte %10010
.byte %10010
.byte %10010
.byte %00000 ; M

.byte %10010
.byte %11010
.byte %10110
.byte %10010
.byte %10010
.byte %00000 ; N

.byte %01100
.byte %10010
.byte %10010
.byte %10010
.byte %01100
.byte %00000 ; O

; 80-95
.byte %11100
.byte %10010
.byte %11100
.byte %10000
.byte %10000
.byte %00000 ; P

.byte %01100
.byte %10010
.byte %10010
.byte %10110
.byte %01110
.byte %00000 ; Q

.byte %11100
.byte %10010
.byte %11100
.byte %10100
.byte %10010
.byte %00000 ; R

.byte %01110
.byte %10000
.byte %01100
.byte %00010
.byte %11100
.byte %00000 ; S

.byte %11100
.byte %01000
.byte %01000
.byte %01000
.byte %01000
.byte %00000 ; T

.byte %10010
.byte %10010
.byte %10010
.byte %10010
.byte %01100
.byte %00000 ; U

.byte %10100
.byte %10100
.byte %10100
.byte %10100
.byte %01000
.byte %00000 ; V

.byte %10010
.byte %10010
.byte %10010
.byte %11110
.byte %10010
.byte %00000 ; W

.byte %10010
.byte %10010
.byte %01100
.byte %10010
.byte %10010
.byte %00000 ; X

.byte %10100
.byte %10100
.byte %01000
.byte %01000
.byte %01000
.byte %00000 ; Y

.byte %11110
.byte %00010
.byte %01100
.byte %10000
.byte %11110
.byte %00000 ; Z

.byte %01100
.byte %01000
.byte %10000
.byte %01000
.byte %01100
.byte %00000 ; {

.byte %00100
.byte %00100
.byte %00100
.byte %00100
.byte %00100
.byte %00000 ; |

.byte %01100
.byte %00100
.byte %00010
.byte %00100
.byte %01100
.byte %00000 ; }

.byte %01010
.byte %10100
.byte %00000
.byte %00000
.byte %00000
.byte %00000 ; ~

.byte %10100
.byte %01010
.byte %10100
.byte %01010
.byte %10100
.byte %01010 ; checkerboard thing?
