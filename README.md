# SRAM
Tiny Tapout Project

Technical Specifications of the SRAM : (Front end RTL ) 
The signals : Inputs --- CLK , RESET, DATA_IN (write), SELECT, Enable signals for R/W , control signals (direction)  
Outputs --- read  
Address decoding : format — One Hot Encoding . 
Operations : Read — Asynchronous  Write — Synchronous 


State Machine Transitions (Approx) :  
1. IDLE : write enable is low , read enable is low , control signals are low , read and write signals are low.
2.  2. WRITE : write enable high , chip set high , address <value> , data <value to be written>., read enable low.
		data in is  given to the desired address. 
3. READ : read enable high , chip set low , address <value > , data <value to be read> , write enable low.
		data is read out . (Accessed from the specified address).


NOTE: operations are ACTIVE HIGH based.



Back End _spec:  
requires 6 transistors per SRAM cell.  
Approx cell (estimated Value) = 64 cells.
