# Category A Enhancement: Unbounded Grid Size
# Category B Enhancement: Option 1 - Improve the random number generator by implementing (and citing in a comment) a formal pseudo-random generation function.

.data
character:  .byte 0,0
box:        .byte 0,0
target:     .byte 0,0
size:       .byte 8
playerColour: .word 0x0000ff
boxColour: .word 0x964b00
targetColour: .word 0xff0000
wallColour: .word 0xffffff
empty: .word 0x000000
winning_message: .string "Congratulations! You won! Press the down key to restart or the up key to exit.\n"

.globl main
.text

main:
    # TODO: Before we deal with the LEDs, generate random locations for
    # the character, box, and target. static locations have been provided
    # for the (x,y) coordinates for each of these elements within the 8x8
    # grid. 
    # There is a rand function, but note that it isn't very good! You 
    # should at least make sure that none of the items are on top of each
    # other.

reset:
    la t2, character
    call rand
    sb a0, 0(t2)
    call rand
    sb a0, 1(t2)

resetBox:    
    la t2, box
    call rand
    sb a0, 0(t2)
    call rand
    sb a0, 1(t2)
    
    lb t3, 0(t2)
    beq t3, zero, resetBox
    
    la t4, size
    lb t4, 0(t4)
    addi t4, t4, -1
    beq t3, t4, resetBox
    
    la t0, character
    lb t1, 0(t0)
    beq t1, t3, resetBox
    
    lb t3, 1(t2)
    beq t3, zero, resetBox
    
    la t4, size
    lb t4, 1(t4)
    addi t4, t4, -1
    beq t3, t4, resetBox
    
    la t0, character
    lb t1, 1(t0)
    beq t1, t3, resetBox
    
    la t0, box
    lb a0, 0(t0)
    
resetTarget:   
    la t2, target
    call rand
    sb a0, 0(t2)
    call rand
    sb a0, 1(t2)
    
    la t3, box
    lw t4, 0(t3)
    lw t6, 0(t2)
    beq t6, t4, resetTarget
    
    lw t4, 1(t3)
    lw t6, 1(t2)
    beq t6, t4, resetTarget

    # TODO: Now, light up the playing field. Add walls around the edges
    # and light up the character, box, and target with the colors you have
    # chosen. (Yes, you choose, and you should document your choice.)
    # Hint: the LEDs are an array, so you should be able to calculate 
    # offsets from the (0, 0) LED.
    
display:
    li t5, 0
    li t6, 0
    la t2, size
    lb t2, 0(t2)
    addi t2, t2, 1
    loop1:
        loop2:
            la a0, empty
            beq t5, zero, drawWall
            beq t6, zero, drawWall
            beq t5, t2, drawWall
            beq t6, t2, drawWall
            j continueLoop2
            drawWall:
                la a0, wallColour
            continueLoop2:
            lw a0, 0(a0)
            mv a1, t5
            mv a2, t6
            call setLED
            
            addi t5, t5, 1
            ble t5, t2, loop2
        li t5, 0
        addi t6, t6, 1 
        ble t6, t2, loop1
        
     la t2, target
     lb t0, 0(t2)
     addi t0, t0, 1
     lb t1, 1(t2)
     addi t1, t1, 1
     la t2, targetColour
     lw t2, 0(t2)
     mv a0, t2
     mv a1, t0
     mv a2, t1
     call setLED
     
     la t2, box
     lb t0, 0(t2)
     addi t0, t0, 1
     lb t1, 1(t2)
     addi t1, t1, 1
     la t2, boxColour
     lw t2, 0(t2)
     mv a0, t2
     mv a1, t0
     mv a2, t1
     call setLED

     la t2, character
     lb t0, 0(t2)
     addi t0, t0, 1
     lb t1, 1(t2)
     addi t1, t1, 1
     la t2, playerColour
     lw t2, 0(t2)
     mv a0, t2
     mv a1, t0
     mv a2, t1
     call setLED
     la t0, box
     lb t1, 0(t0)
     lb t2, 1(t0)
     la t0, target
     lb t3, 0(t0)
     lb t4, 1(t0)
     bne t1, t3, noVictory
     bne t2, t4, noVictory
 victoryMessage:
     la a0, winning_message
     li a7, 4
     ecall
 
 afterVictory:
     call pollDpad
     beq a0, zero, exit
     li t0, 1 
     beq a0, t0, reset
     j afterVictory

 noVictory:
     
    # TODO: Enter a loop and wait for user input. Whenever user input is
    # received, update the grid with the new location of the player and
    # if applicable, box and target. You will also need to restart the
    # game if the user requests it and indicate when the box is located
    # in the same position as the target.

gameLoop:  
    call pollDpad
    beq a0, zero, moveUp
    li t0, 2
    beq a0, t0, moveLeft
    li t0, 1
    beq a0, t0, moveDown
    li t0, 3
    beq a0, t0, moveRight
    j display

moveUp:
    la t0, character
    lb t1, 1(t0)
    beq t1, zero, gameLoop
    lb t2, 0(t0)
    la t3, box
    lb t4, 0(t3)
    lb t5, 1(t3)
    bne t2, t4, moveUpWithoutBox
    addi t6, t1, -1
    bne t6, t5, moveUpWithoutBox
    beq t5, zero, gameLoop 
    addi t5, t5, -1
    sb t5, 1(t3)
    
moveUpWithoutBox:
    addi t1, t1, -1
    sb t1, 1(t0)
    j display
    
moveLeft:
    la t0, character
    lb t1, 0(t0)
    lb t2, 1(t0)
    la t3, box
    lb t4, 0(t3)
    lb t5, 1(t3)
    beq t1, zero, gameLoop
    bne t2, t5, moveLeftWithoutBox
    addi t6, t1, -1
    bne t6, t4, moveLeftWithoutBox
    beq t4, zero, gameLoop 
    addi t4, t4, -1
    sb t4, 0(t3)
    
moveLeftWithoutBox:
    addi t1, t1, -1
    sb t1, 0(t0)
    j display
    
moveDown:
    la t0, character
    lb t1, 1(t0)
    lb t6, 0(t0)
    la t3, box
    lb t4, 0(t3)
    lb t5, 1(t3)
    la t2, size
    lb t2, 0(t2)
    addi t2,t2, -1
    beq t1, t2, gameLoop
    bne t6, t4, moveDownWithoutBox
    addi t2, t1, 1
    bne t2, t5, moveDownWithoutBox
    la t2, size
    lb t2, 0(t2)
    addi t2, t2, -1
    beq t2, t5, gameLoop
    addi t5, t5, 1
    sb t5, 1(t3)
    
moveDownWithoutBox:
    addi t1, t1, 1
    sb t1, 1(t0)
    j display
    
moveRight:
    la t0, character
    lb t1, 0(t0)
    lb t6, 1(t0)
    la t2, size
    lb t2, 0(t2)
    la t3, box
    lb t4, 0(t3)
    lb t5, 1(t3)
    addi t2, t2, -1
    beq t1, t2, gameLoop
    bne t6, t5, moveRightWithoutBox
    addi t2, t4, -1
    bne t1, t2, moveRightWithoutBox
    la t2, size
    lb t2, 0(t2)
    addi t2, t2, -1
    beq t4, t2, gameLoop
    addi t4, t4, 1
    sb t4, 0(t3)
    
moveRightWithoutBox:
    addi t1, t1, 1
    sb t1, 0(t0)
    j display
    
    # TODO: That's the base game! Now, pick a pair of enhancements and
    # consider how to implement them.
 
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit
     
# Takes in a number in a0, and returns a (sort of) (okay no really) random 
# number from 0 to this number (exclusive)
rand:
    # I used the linear congruential generator for the Category B enhancement.
    # Chapter 3 pseudo-random numbers generators - university of Arizona. (n.d.). 
    #           https://www.math.arizona.edu/~tgk/mc/book_chap3.pdf 
    la a6, size
    lb a6, 0(a6)
    li a7, 30
    ecall
    mv a1, a0 # x
    li a2, 16807 # a
    li a3, 2147483647 # m
    mul a1, a1, a2
    remu a1, a1, a3
    remu a1, a1, a6
    mv a0, a1
    jr ra

    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra