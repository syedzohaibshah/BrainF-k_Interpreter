# Brainf**k Interpreter

This project implements a **brainf\*\*k** interpreter in x86 32-bit assembly language using NASM syntax.  
**brainf\*\*k** is a minimalist programming language that operates on a memory tape and simulates a Turing machine using only eight commands.  

The interpreter reads a **brainf\*\*k** program and executes it instruction by instruction, managing memory with a tape-like array (cells) and supporting loops through a manually managed stack.

Despite its simplicity, **brainf\*\*k** is theoretically capable of expressing any computable function, showing how complex computation can emerge from simple building blocks.

---

## x86 32-bit Assembly

This interpreter was written in **x86 NASM syntax**, targeting Linux via `int 0x80` system calls.

### Registers Used

- `esi`: Points to the current instruction (instruction pointer)  
- `edi`: Points to the current cell on the memory tape (data pointer)  
- `ebx`: Points to the top of the loop stack  
- `ecx`, `edx`: Used in syscalls to specify buffer address and length  
- `eax`: Holds syscall number (`4` for write, `1` for exit)  

### Instructions Used

- `mov`, `inc`, `dec` for memory and control  
- `cmp`, `je`, `jne` for condition checks  
- `int 0x80` for invoking Linux kernel services  
- Manual address manipulation for simulating a stack (`[ebx]`, `ebx ± 4`)  

The core interpreter works by:

- Reading instructions sequentially from a program array (`bf_program`)  
- Maintaining a memory tape (`cells`) and a data pointer (`edi`)  
- Using a stack to handle nested loops (`stack`)  

---

## Instruction Code Block Explanation

- `+` (0x2B) `incr`: Increment the byte at `edi`  
- `-` (0x2D) `decr`: Decrement the byte at `edi`  
- `>` (0x3E) `next`: Move `edi` one cell to the right  
- `<` (0x3C) `prev`: Move `edi` one cell to the left  
- `.` (0x2E) `print`: Use `sys_write` to output the byte at `edi`  
- `[` (0x5B) `open_loop`:  
  - If the cell is zero, jump forward past matching `]`  
  - Otherwise, push the address on the stack  
- `]` (0x5D) `close_loop`:  
  - If the cell is non-zero, jump back to the matching `[`  
  - Otherwise, pop the stack  

---

## Loop Management

### `[ Open Loop Handling`

- If the cell is `0`, skip forward to the matching `]`  
- Otherwise, push the current `esi` (instruction pointer) onto the stack  

### `] Close Loop Handling`

- If the current cell is not `0`, jump back to the saved `[` address  
- If the cell is `0`, pop from the stack and continue  
- This ensures correct behavior even for nested loops  

---

## Test Programs

### Program 1 — Simple Output `'H'`

```brainf**k
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.
Step by step Execution to print ‘H’ :
-  Set cell [0] = 72 
- The + command is repeated 72 times. 
- Each one triggers: 
-incr: 
-inc byte [edi]       ; adds 1 to cell[0] 
-  After 72 + commands, cell[0] = 72 
- The . command triggers the print label in assembly 
- This prints the value 72 as an ASCII character: 'H'
