.text
.globl _start

_start:
    # --- Menu Display ---
    la $a0, menu            # print string(menu)
    li $v0, 4
    syscall

    la $a0, opt1            # print string(opt1)
    li $v0, 4
    syscall

    la $a0, opt2            # print string(opt2)
    li $v0, 4
    syscall

    la $a0, opt3            # print string(opt3)
    li $v0, 4
    syscall

    la $a0, opt4            # print string(opt4)
    li $v0, 4
    syscall
    
    la $a0, new_l           # print string(new_l)
    li $v0, 4
    syscall
    
    la $a0, menu            # print string(menu)
    li $v0, 4
    syscall

    la $a0, req             # print string(req)
    li $v0, 4
    syscall

    li $v0, 5               # read int(ans)
    syscall
    move $t0, $v0

    beq $t0, 1, DoInsert
    beq $t0, 2, DoDelete
    beq $t0, 3, DoPrint
    beq $t0, 0, exit

    j _start

# ------------------------------------------------------------------
# CASE 1: INSERT
# ------------------------------------------------------------------
DoInsert:
    la $a0, enter
    li $v0, 4
    syscall

    li $v0, 5               # read int from user
    syscall
    
    # --- Calling Sequence for InsertNode ---
    move $a0, $v0           # Argument 1 ($a0): value to insert
    lw   $a1, head          # Argument 2 ($a1): current list head
    jal InsertNode          # Call subroutine
    # ---------------------------------------
    
    sw  $v0, head           # Store the returned head address

    la $a0, added           # print "Value added"
    li $v0, 4
    syscall
    j _start

# ------------------------------------------------------------------
# PROCEDURE: InsertNode
#
# Algorithm (Pseudo-code):
#   Create a new node (call CreateNode)
#   If list is empty OR new_value < head.value:
#       new_node.next = head
#       return new_node (as new head)
#   Else:
#       current = head
#       While (current.next != NULL AND current.next.value < new_value):
#           current = current.next
#       new_node.next = current.next
#       current.next = new_node
#       return head
# ------------------------------------------------------------------
InsertNode:
    # --- Prologue ---
    addi $sp, $sp, -20      # Allocate stack frame
    sw $ra, 0($sp)          # Save return address
    sw $s0, 4($sp)          # Save s0
    sw $s1, 8($sp)          # Save s1
    sw $s2, 12($sp)         # Save s2
    sw $s3, 16($sp)         # Save s3 (padding/extra safety)
    # ----------------

    move $s0, $a0           # $s0 = Data value to insert
    move $s1, $a1           # $s1 = Current head address

    # Call CreateNode to get a new memory block
    # --- Calling Sequence for CreateNode ---
    move $a0, $s0           # Arg 1: data
    jal CreateNode          
    # ---------------------------------------
    
    move $s2, $v0           # $s2 = Address of new node

    # CASE 1: Empty list or insert at very beginning (new < head)
    beq $s1, $zero, insert_at_start
    lw $t0, 0($s1)          # Load head data
    bgt $t0, $s0, insert_at_start

    # CASE 2: Search for sorted position in middle or end
    move $t1, $s1           # current = head
search_pos_loop:
    lw $t2, 4($t1)          # t2 = current->next
    beq $t2, $zero, link_it # End of list reached
    lw $t3, 0($t2)          # Data of next node
    bgt $t3, $s0, link_it   # Found spot where next > new value
    move $t1, $t2           # Move to next node
    j search_pos_loop

link_it:
    sw $t2, 4($s2)          # newNode->next = current->next
    sw $s2, 4($t1)          # current->next = newNode
    move $v0, $s1           # Head remains unchanged (return original head)
    j insert_exit

insert_at_start:
    sw $s1, 4($s2)          # newNode->next = old head
    move $v0, $s2           # New node becomes the new head

insert_exit:
    # --- Epilogue ---
    lw $ra, 0($sp)          # Restore return address
    lw $s0, 4($sp)          # Restore s0
    lw $s1, 8($sp)          # Restore s1
    lw $s2, 12($sp)         # Restore s2
    lw $s3, 16($sp)         # Restore s3
    addi $sp, $sp, 20       # Deallocate stack frame
    jr $ra                  # Return
    # ----------------

# ------------------------------------------------------------------
# PROCEDURE: CreateNode
#
# Algorithm (Pseudo-code):
#   Allocate 8 bytes of dynamic memory (syscall 9)
#   Store 'data' in the first 4 bytes
#   Store 0 (NULL) in the next 4 bytes (pointer)
#   Return address of the allocated block
# ------------------------------------------------------------------
CreateNode:
    # --- Prologue ---
    # (Leaf procedure, no stack allocation needed)
    # ----------------
    
    move $t0, $a0           # Save data temporarily
    
    li $a0, 8               # Request 8 bytes
    li $v0, 9               # sbrk syscall
    syscall

    sw $t0, 0($v0)          # node->data = value
    sw $zero, 4($v0)        # node->next = NULL
    
    # --- Epilogue ---
    jr $ra                  # Return
    # ----------------

# ------------------------------------------------------------------
# CASE 2: DELETE
# ------------------------------------------------------------------
DoDelete:
    lw $t0, head
    beq $t0, $zero, empty_list

    la $a0, del1            # print string(del1)
    li $v0, 4
    syscall

    li $v0, 5               # read Int(val)
    syscall
    
    # --- Calling Sequence for DeleteNode ---
    move $a0, $v0           # Argument 1 ($a0): value to delete
    lw   $a1, head          # Argument 2 ($a1): current head
    jal DeleteNode          # Call subroutine
    # ---------------------------------------
    
    sw $v0, head            # Update head with return value
    j _start

# ------------------------------------------------------------------
# PROCEDURE: DeleteNode
#
# Algorithm (Pseudo-code):
#   current = head, previous = null
#   While (current != null):
#       If (current.data == value):
#           If (previous == null):  (Deleting head)
#               head = current.next
#           Else:
#               previous.next = current.next
#           Print "Deleted"
#           Return head
#       previous = current
#       current = current.next
#   Print "Not Found"
#   Return head
# ------------------------------------------------------------------
DeleteNode:
    # --- Prologue ---
    addi $sp, $sp, -12      # Allocate stack frame
    sw $ra, 0($sp)          # Save return address
    sw $s0, 4($sp)          # Save s0
    sw $s1, 8($sp)          # Save s1
    # ----------------

    move $s0, $a0           # $s0 = value to delete
    move $s1, $a1           # $s1 = head address

    move $t0, $s1           # current
    move $t1, $zero         # previous

search_loop:
    beq $t0, $zero, not_found # if NULL, reached end -> not found
    lw $t2, 0($t0)            # load data of current node
    beq $t2, $s0, found       # if data == target -> found
    move $t1, $t0             # current becomes previous
    lw $t0, 4($t0)            # move to next node
    j search_loop

found:
    la $a0, del2            # Print "Value deleted!"
    li $v0, 4
    syscall
    
    beq $t1, $zero, delete_head # If previous == 0, we are deleting the head
    lw $t3, 4($t0)              # $t3 = current->next
    sw $t3, 4($t1)              # previous->next = current->next
    move $v0, $s1               # Head stays the same
    j delete_exit

delete_head:
    lw $v0, 4($t0)          # New head = current->next
    j delete_exit

not_found:
    la $a0, n_found         # Print "Not found"
    li $v0, 4
    syscall
    move $v0, $s1           # Return original head unchanged
    j delete_exit

delete_exit:
    # --- Epilogue ---
    lw $ra, 0($sp)          # Restore return address
    lw $s0, 4($sp)          # Restore s0
    lw $s1, 8($sp)          # Restore s1
    addi $sp, $sp, 12       # Deallocate stack
    jr $ra                  # Return
    # ----------------

# ------------------------------------------------------------------
# CASE 3: PRINT
# ------------------------------------------------------------------
DoPrint:
    lw $t0, head            # $t0 = head
    beq $t0, $zero, empty_list

    # --- Calling Sequence for PrintList ---
    lw $a0, head            # Argument 1: head address
    jal PrintList           # Call subroutine
    # --------------------------------------
    
    la $a0, new_l           # print newline
    li $v0, 4
    syscall
    la $a0, new_l           # print newline
    li $v0, 4
    syscall
    j _start

# ------------------------------------------------------------------
# PROCEDURE: PrintList
#
# Algorithm (Pseudo-code):
#   current = head
#   While (current != null):
#       print current.data
#       print " " (space)
#       current = current.next
# ------------------------------------------------------------------
PrintList:
    # --- Prologue ---
    # (Leaf procedure, no stack allocation needed)
    # ----------------

    move $t0, $a0           # t0 = current node

print_loop:
    beq $t0, $zero, end_print_loop
    lw $a0, 0($t0)          # load data
    li $v0, 1               # print int
    syscall

    li $a0, 32              # ASCII for space
    li $v0, 11              # print char
    syscall

    lw $t0, 4($t0)          # current = current->next
    j print_loop

end_print_loop:
    # --- Epilogue ---
    jr $ra                  # Return
    # ----------------

empty_list:
    la $a0, empty
    li $v0, 4
    syscall
    j _start

exit:
    li $v0, 10
    syscall

# ------------------------------------------------------------------
# DATA SEGMENT
# ------------------------------------------------------------------
.data
menu:   .asciiz "------------------------"
opt1:   .asciiz "\n(1) Insert data!"
opt2:   .asciiz "\n(2) Delete data!"
opt3:   .asciiz "\n(3) Show list ascending!"
opt4:   .asciiz "\n(0) Exit Program!"
new_l:  .asciiz "\n"
req:    .asciiz "\nPlease choose an option:\n"
enter:  .asciiz "Enter a value\n"
added:  .asciiz "Value added!\n\n"
del1:   .asciiz "Delete value\n"
del2:   .asciiz "Value deleted!\n\n"
n_found:.asciiz "The value you entered was not found\n\n"
empty:  .asciiz "The list is empty\n\n"

head:   .word 0
