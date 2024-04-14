# Assignment: MIPS Programming
# MIPS Procedures
# CSC 211
# Original main (and stubs) and macros written by Jerod Weinman

# Because MARS does not heed the .ent directive to specify the entry point,
# we must put the "main" routine first. Otherwise, we'd include main in the
# .globl symbols below and uncomment the following line:
#.ent main

# Ensure the following procedure labels are globally visible
.globl swap, byteflip, extremes, product

.data                             # Global values stored in memory

ramanujan: .word 1729
simerka:   .word  561

.text                             # Start generating instructions

        
# main
# Run the assignment procedure(s).
# (main is not a special name in MARS, but we label it anyway for familiarity.)
# You may edit anything within main for testing, as it will not be autograded
main:
  # Problem 1 (Swap)
  la   $a0, ramanujan             # Load arguments (addresses) into registers
  la   $a1, simerka      
  jal  swap                       # Call the procedure
  la   $t0, ramanujan             # (Re)load addresses into registers, because
  la   $t1, simerka               # argument registers are not preserved
  lw   $s0, 0($t0)                # Dereference pointers into saved registers
  lw   $s1, 0($t1)
  
  # Problem 2 (Byteflip)
  li   $a0, 0xBA5E		  # Load arguments into register $a0
  sll  $a0, $a0, 16               # Shift 0xBA5E into the upper 16 bits
  ori  $a0, $a0, 0xBA77           # Load 0xBA5EBA77 into $a0
  jal  byteflip			  # Call the procedure
  move $t1, $v0 		  # Copy the results into $t1
  
  # Problem 3 (Extremes)
  li   $a0, 4                     # Load arguments into registers
  li   $a1, 3               
  li   $a2, 2
  li   $a3, 1
  jal  extremes                   # Call the procedure
  move $s2, $v0                   # Copy results into saved registers
  move $s3, $v1
  
  # Problem 4 (Product)      
  li   $a0, 2			  # Load arguments into registers      
  li   $a1, 5
  jal  product
  move $s4, $v0
  
  # Exit/Terminate       
  li   $v0, 10                    # Load SYSCALL service number for exit
  syscall                         # Make system call (terminating program)
# END MAIN


# Problem 1
# The swap procedure takes two memory addresses in $a0 and $a1 and transposes the values at
# the memory addresses in $a0 and $a1.
swap:
  lw   $t0, 0($a0)		  # Dereference the pointer in $a0 and store its value in $t0
  lw   $t1, 0($a1)		  # Dereference the pointer in $a1 and store its value in $t1
  sw   $t1, 0($a0)		  # Store the dereferenced value from $a1 at the memory address $a0
  sw   $t0, 0($a1)		  # Store the dereferenced value from $a0 at the memory address $a1
  				  # At this point, we have swapped the values at the memory addresses $a0 and $a1
  jr   $ra                        # Return to caller
#END swap


# Problem 2
# The byteflip procedure takes a single 32 bit integer in $a0 and flips the byte order of that integer,
# returning the byte-flipped integer in the register $v0.
byteflip:
  # By flipping a byte, we mean put a byte in the position it would be if the byte order were reversed.
  # Flipping byte 3 of $a0 to byte position 0
  srl  $v0, $a0, 24               # Flip byte 3 of $a0 and store it in $v0 at byte position 0
  
  # Flipping byte 2 of $a0 to byte position 1
  srl  $t0, $a0, 8		  # Flip byte 2 of $a0 and store it in $t0 at byte position 1
  andi $t0, $t0, 0xFF00		  # Mask out all bytes in $t0 other than the flipped version of byte 2 of $a0
  or   $v0, $v0, $t0              # Mask in flipped byte 2 of $a0 into $v0 at byte position 1
  
  # Flipping byte 1 of $a0 to byte position 2
  sll  $t0, $a0, 8		  # Flip byte 1 of $a0 and store it into $t0 at byte position 2
  lui  $t1, 0x00FF                # Create a mask to filter out all bytes in $t0 other than the flipped version of byte 1 in $t0
  and  $t0, $t0, $t1              # Mask out all bytes in $t0 other than the flipped version of byte 1 of $a0
  or   $v0, $t0, $v0              # Mask in flipped byte 1 of $a0 into $v0 at byte position 2
  
  # Flipping byte 0 of $a0 to byte position 3
  sll  $t0, $a0, 24               # Flip byte 0 of $a0 and store it in $t0 at byte position 3
  or   $v0, $t0, $v0              # Mask in flipped byte 0 of $a0 into $v0 at byte position 3
  jr   $ra                        # Return to caller
#END byteflip


# Problem 3
# The extremes procedure takes four 32-bit signed integers in $a0-$a3 and returns the smallest of the four in $v0 and the largest
# of the four values in $v1.
extremes:
  move $v0, $a0			  # Set the current minimum to $a0
  move $v1, $a0			  # Set the current maximum to $a0
  
  # Compare current maximum and minimum to $a1 and update accordingly
  slt  $t0, $a1, $v0		  # Check if $a1 < $v0
  beq  $t0, $zero, check_a1_max	  # If $a1 is not less than $v0, $a1 is not the minimum. Check if it is the maximum
  move $v0, $a1			  # Otherwise, update minimum to $a1
check_a1_max:
  slt  $t0, $v1, $a1		  # Check if $v1 < $a1
  beq  $t0, $zero, check_a2_min	  # If $v1 is not less than $a1, then $a1 is not the maximum.
  move $v1, $a1			  # Otherwise, update maximum to $a1
  
  # Compare current maximum and minimum to $a2 and update accordingly
check_a2_min:
  slt  $t0, $a2, $v0		  # Check if $a2 < $v0
  beq  $t0, $zero, check_a2_max	  # If $a2 is not less than $v0, $a2 is not the minimum. Check if it is the maximum
  move $v0, $a2			  # Otherwise, update minimum to $a2
check_a2_max:
  slt  $t0, $v1, $a2		  # Check if $v1 < $a2
  beq  $t0, $zero, check_a3_min   # If $v1 is not less than $a2, then $a2 is not the maximum
  move $v1, $a2			  # Otherwise, update the maximum to $a2
  
  # Compare current maximum and minimum to $a3 and update accordingly
check_a3_min:
  slt  $t0, $a3, $v0		  # Check if $a3 < $v0
  beq  $t0, $zero, check_a3_max   # If $a3 is not less than $v0, then $a3 is not the minimum. Check if it is the maximum
  move $v0, $a3			  # Otherwise, update minimum to $a3
check_a3_max:
  slt  $t0, $v1, $a3		  # Check if $v1 < $a3
  beq  $t0, $zero, exit_extremes  # If $v1 is not less than $a3, then $v1 is the maximum and return to caller
  move $v1, $a3			  # Otherwise, update maximum to $a3
exit_extremes:
  jr   $ra                        # Return to caller
#END extremes

        
# Problem 4
# The product procedure multiplies $a0, some value, by $a1, a non-negative integer, using repeated addition
# The result is returned in register $v0. As a precondition, we do not control for overflow.
product:
  move $v0, $zero		  # Initialize the product to 0
  beq  $a1, $zero, return_prod    # If $a1 == 0, then product is 0 and return to caller
  
  # We will repeatedly add $a0 to $v0 $a1 times
add_a0:
  addi $a1, $a1, -1		  # Decrement $a1, our iteration variable
  add  $v0, $a0, $v0		  # Add $a0 to $v0
  bne  $a1, $zero, add_a0         # If $a1 != 0, continue to next iteration and add $a0 to $v0 again
  
return_prod:
  jr   $ra                        # Return to caller
#END product
