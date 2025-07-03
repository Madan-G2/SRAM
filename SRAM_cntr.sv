//Main inputs to the system clk and reset
module sram #( parameter ADDR_WIDTH = 8,      //top-level
              parameter DATA_WIDTH = 8,
              parameter MEM_SIZE = 1<<ADDR_WIDTH );
  (  input logic  clk, 
     input logic reset_n,
     input logic chip_enable_n, //to enable or disable the entire SRAM module-active low
     input logic write_enable_n, //to enable write signal --low
     input logic read_enable_n,  //read --low
   input logic [ADDR_WIDTH -1] = address,
   input logic [DATA_WIDTH -1] = data_in,      //input 
   output logic [DATA_WIDTH -1] = data_out //output from the SRAM
  );
  typdef enum logic [2:0] {
    IDLE = 3'b001,
    WRITE = 3'b010,
    READ = 3'b100 }state;
  state current_state,next_state;
  
endmodule
