# timetest.S
# Test harness for the time_to_iters function
# Written by Janet Davis, 23 October 2013
# Last revised by Janet Davis, 24 October 2013

#define OFF                 0x0
#define ON                  0x1
#define CLOCK_RATE_HZ       4000000 // Cycles per second for this CPU
#define CPI                 1       // Cycles per instruction
#define IC                  3       // Instructions per delay loop
#define MICROSEC_PER_SEC    1000000 // Microseconds per second

.set noreorder          # Avoid reordering instructions
.text                   # Start generating instructions
.globl main             # The label should be globally known
.ent main               # The label marks an entry point

# Main program.
# Test time_to_iters computation.
# The light should blink at a rate of 1 Hz.
main:
   

    # Compute number of delayloop iterations for blinking at 1Hz
    li      $a0, 500000         # Half a second, in microsec
    jal     time_to_iters       # Call time_to_iters procedure.
    nop                         # Delay slot
    add     $s1, $v0, $zero     # Store result in $s1

    # Blink on and off 60 times; should take 60 seconds to finish blinking.
    li      $s2, 60             # Set countdown to 60.
loop:
    li      $t0, 1              # Turn LED on.
    sw      $t0, 0($s0)
    move    $a0, $s1            # Call delayloop on the computed value.
    jal     delayloop
    nop                         # Delay slot
    li      $t0, 0              # Turn LED off.
    sw      $t0, 0($s0)
    move    $a0, $s1            # Call delayloop on the computed value.
    jal     delayloop
    nop                         # Delay slot
    addi    $s2, $s2, -1        # Decrement countdown
    bnez    $s2, loop           # Loop while countdown > 0    
    nop                         # Delay slot
forever:
    j forever                   # Infinite loop that does nothing.
    nop
.end main                       # Marks the end of the program

# Compute number of delay loops in a given period of time 
# (measured in microseconds)
time_to_iters:
    # The number of iterations is calculated like so,
    # result = (microsec / (CPI * IC)) * (CLOCK_RATE_HZ / MICROSEC_PER_SEC  )
    # to avoid overflow in calculations.
    
    # $t0 = CLOCK_RATE_HZ / MICROSEC_PER_SEC
    li       $t2, 4000000           # Load CLOCK_RATE_HZ constant
    li       $t3, 1000000           # Load MICROSEC_PER_SEC constant
    divu     $t2, $t3               # Divide CLOCK_RATE_HZ by MICROSEC_PER_SEC
    mflo     $t0		    # Store the quotient of CLOCK_RATE_HZ divded by MICROSEC_PER_SEC into $t0
   
    # $t1 = IC * CPI
    li       $t3, 3               # Load IC constant
    li       $t4, 1              # Load CPI constant
    multu    $t4, $t3            # Multiply IC * CPI
    mflo     $t1                 # Copy result of IC * CPI to $t1
    nop                          # Delay 
    nop                          # Delay
    
    # $t1 = microsec / (IC * CPI)
    divu     $a0, $t1		 # Divide $a0 by (CPI * IC)
    mflo     $t1                 # Get result of microsec / (CPI * IC)
    mfhi     $t2                 # Store remainder

    # result = (microsec / (CPI * IC)) * (CLOCK_RATE_HZ / MICROSEC_PER_SEC)
    multu    $t0, $t1            # Multiply $t0 and $t1
    mflo     $v0                 # Store result in $v0
    nop                          # Delay 
    nop                          # Delay
    add      $v0, $v0, $t2       # Add remainder
    jr       $ra                 # Return to caller
    nop                          # Delay slot

# Delay for the given number of loop iterations (3 cycles/iteration)
# Precondition: $a0 > 0
delayloop:
    addi    $a0, $a0, -1
    bnez    $a0, delayloop
    nop
    jr      $ra
    nop

