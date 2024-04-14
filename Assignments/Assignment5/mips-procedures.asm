# Assignment: MIPS Procedures
# CSC 211
# Original main (and stubs) and macros written by Jerod Weinman

# Because MARS does not heed the .ent directive to specify the entry point,
# we must put the "main" routine first. Otherwise, we'd include main in the
# .globl symbols below and uncomment the following line:
#.ent main

# Ensure the following procedure labels are globally visible
.globl remainder, gcd, gcdtail, count, reverse

.data                             # Arrays and strings for global processing

# The following array has 100 random numbers in [0-10]
numbers: .word 9, 6, 2, 2, 1, 5, 5, 10, 1, 7, 8, 2, 4, 0, 3, 9, 3, 4, 8, 4, 6,
               8, 4, 9, 8, 4, 0, 7, 6, 5, 5, 0, 0, 1, 9, 6, 6, 5, 7, 6, 1, 7,
               7, 2, 8, 0, 0, 2, 0, 4, 2, 6, 8, 4, 0, 4, 8, 6, 2, 10, 6, 6, 0,
               7, 4, 10, 5, 5, 1, 1, 3, 7, 4, 4, 8, 5, 8, 8, 8, 10, 8, 5, 6, 3,
               5, 3, 0, 2, 2, 0, 4, 3, 3, 6, 6, 1, 0, 6, 9, 7

message: .asciiz "Hello, world!"
        
.text                             # Start generating instructions

# Parameterized macros for text output
.macro print_str (%addr)
  la   $a0, %addr                 # Load argument (string pointer) into register
  li   $v0, 4                     # Load "print string" SYSCALL service number
  syscall                         # Make system call (printing string)
.end_macro

.macro putchar (%ch)
  li   $a0, %ch                   # Load argument (ASCII char) into register
  li   $v0, 11                    # Load "print char" SYSCALL service number
  syscall
.end_macro

        
# main        
# Run the assignment procedure(s).
# You may edit anything within main for testing, as it will not be graded
main:
  # Problem 1 (Remainder)
  li   $a0, 1                     # Load arguments into registers
  li   $a1, 1
  jal  remainder                  # Call the procedure
  move $s2, $v0                   # Copy result into saved registers

  # Problem 2a (GCD)
  li   $a0, 66                    # Load arguments into registers
  li   $a1, 24
  jal  gcd                        # Call the procedure
  move $s3, $v0
  
  # Problem 2b (GCDTail)
  li   $a0, 66			  # Load arguments into registers
  li   $a1, 24			  
  jal  gcdtail			  # Call the procedure
  move $s3, $v0
        
  # Problem 3 (Frequency Count)
  la   $a0, numbers               # Load argument (array pointer, beginning)
  #addi $a0, $a0, 32               # Example: shift pointer 8 ints into array
  li   $a1, 2                     # Load argument for length
  li   $a2, 9                     # Load argument for sought      
  jal  count                      # Call the procedure (result is in $v0)

  # Problem 4 (String Reverse)
  print_str(message)              # Invoke macro for output
  putchar('\n')                   # Invoke macro to separate lines ('\n'=0xA)
        
  la   $a0, message               # Load argument (string pointer) into register
  jal  reverse                    # Call the procedure

  print_str(message)              # Invoke macro for output (reversed)
        
        
  li   $v0, 10                    # Load exit SYSCALL service number
  syscall                         # Make system call (terminating program)
# END MAIN



# Problem 1
# The procedure remainder calculates the remainder of $a0, a 32-bit integer, divided by $a1, another 32-bit integer through repeated subtraction.
# Both $a0 and $a1 are assumed to be positive integers, and the remainder is returned in $v0.
# In this procedure, we will be referring to $a0 as a and $a1 as b.
remainder:
  move $v0, $a0			  # Set the return value to a, so we can simply update the return value as the procedure executes
  j    remainder_test             # Jump to the while loop's test, checking if a >= b
remainder_loop:
  sub  $v0, $v0, $a1	          # a = a - b, and update the current return value accordingly
remainder_test:
  slt  $t0, $v0, $a1		  # Check if a < b and store that boolean value in $t0
  beq  $t0, $zero, remainder_loop # If !(a < b), then a >= b. As a result, go to the next iteration of the while loop
                                  # Otherwise, return the updated value in $v0
  jr   $ra                        # Return to caller
#END remainder

        
# Problem 2a
# Use euclid's algorithm to find the greatest common divisor between two 32-bit integers $a0 and $a1 recursively.
# Given that we use the remainder procedure, both $a0 and $a1 are assumed to be positive integers. The greatest common divisor is returned in $v0.
# In this procedure, we will be referring to $a0 as m and $a1 as n.
gcd:
  bne  $a1, $zero, gcd_recur	   # If n != 0, go to recursive case
  move $v0, $a0			   # Otherwise, go to base case and return m
  jr   $ra		   	   # Return to caller
gcd_recur:
  addi $sp, $sp, -8	           # Adjust stack pointer to push 2 items, n and the return address
  sw   $ra, 4($sp)		   # Push $ra onto the stack
  sw   $a1, 0($sp)		   # Push n onto the stack
  jal  remainder		   # Call remainder(m,n)
  move $a1, $v0			   # Move remainder(m,n) into $a1, the second argument register
  lw   $a0, 0($sp)                 # Pop n off the stack and load it into $a0, the first argument register
  jal  gcd			   # Call gcd(n, remainder(m,n))
  lw   $ra, 4($sp)		   # Pop $ra off the stack
  addi $sp, $sp, 8		   # Adjust the stack pointer for the two items popped off the stack 
  jr   $ra                         # Return to caller
#END gcd

# Problem 2b
# The gcdtail procedure uses euclid's algorithm and the rem pseudoisntruction
# to find the greatest common divisor between two 32-bit integers, $a0 and $a1, recursively.
# The greatest common divisor is returned in $v0, and we will refer to $a0 as m and $a1 as n.
gcdtail:
  bne  $a1, $zero, gcdtail_recur   # If n != 0, go to recursive case
  move $v0, $a0			   # Otherwise, go to base case and return m
  jr   $ra			   # Return to caller
gcdtail_recur:
  rem  $t0, $a0, $a1	           # Set $t0 to the remainder of m/n
  move $a0, $a1			   # Set $a0 to n
  move $a1, $t0			   # Set $a1 to the remainder of m/n
  j    gcdtail			   # Call gcdtail(n, remainder of m/n)
#END gcdtail


# Problem 3
# The count procedure returns the frequency of the value k in an array of n items that starts at address p
# Address p is stored at $a0, n is stored in $a1, and k is stored in $a2.
# The frequency of k in the array is returned in the value $v0
# As a precondition, we assume the address provided points to an accessible integer in memory.
# In other words, the length of the array must at least be 1.
count:
  move $v0, $zero           	   # Initialize the frequency of the value k in the array to 0
  sll  $a1, $a1, 2		   # Convert n into a word address offset by multiplying it by 4
  add  $a1, $a0, $a1		   # $a1 = &a[n]
  j    count_test		   # Go to for loop test to iterate over array
count_forloop:
  lw   $t0, 0($a0)		   # $t0 = a[current]
  addi $a0, $a0, 4		   # Increment the address of a[current]
  bne  $t0, $a2, count_test        # If a[current] != k, jump to test
  addi $v0, $v0, 1		   # Otherwise, increment $v0, the frequency of k
count_test:
  bne  $a0, $a1, count_forloop     # If &a[current] != &a[n], go to next integer in the array
  jr   $ra                         # Otherwise, return to caller
#END count


# Problem 4
# Reverses a null-terminated string beginning at address $a0 in place, not using any other memory addresses
# Precondition: the string with address $a0 has at least one character in it besides the null character
reverse:
  move $t0, $a0			   # Copy the base address of the string into $t0
  j    length_test		   # Jump to for loop test for determining the length of the string
length_loop:
  addi $t0, $t0, 1		   # &string[current++]
length_test:
  lbu  $t1, 0($t0)		   # $t1 = string[current]
  bne  $t1, $zero, length_loop     # If string[current] != '\0', go to next character in the string
  addi $t0, $t0, -1		   # Otherwise, $t0 contains the address of the last character, just before the null character
  j    reverse_test		   # Jump to for loop test for reversing the string in place
reverse_loop:
  lbu  $t1, 0($a0)		   # Load our "lower" character in $t1
  lbu  $t2, 0($t0)		   # Load our "upper" character in $t2
  sb   $t1, 0($t0)		   # Store our "lower" character at "upper" character address
  sb   $t2, 0($a0)		   # Store our "upper" character at "lower" character address
  addi $a0, $a0, 1		   # Increment address of our "lower" character
  addi $t0, $t0, -1		   # Decrement address of our "upper" character
reverse_test:                      
  slt  $t1, $a0, $t0		   # Check if $a0, the address of our "lower" character, is less than $t0, the address of our "upper" character
  bne  $t1, $zero, reverse_loop    # If the address of our "lower" character is smaller than the address of our "upper" character, keep swapping characters
  jr   $ra                         # Return to caller
#END reverse
