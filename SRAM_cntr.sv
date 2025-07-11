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

  logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1]; //memory spaces
  logic [MEM_SIZE-1:0] addr_one_hot; //one hot decdng var
  always_comb begin
        addr_one_hot = '0; // initally all are zeros
        if (!ce_n && addr < MEM_SIZE) begin
            addr_one_hot[addr] = 1'b1; 
        end
    end
  always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (!ce_n && !we_n && re_n) begin
                    next_state = WRITE;
                end
                else if (!ce_n && !re_n && we_n) begin
                    next_state = READ;
                end
            end
            WRITE: begin
                if (ce_n || we_n) begin
                    next_state = IDLE;
                end
            end
            READ: begin
                if (ce_n || re_n) begin
                    next_state = IDLE;
                end
            end
            default: next_state = IDLE;
        endcase
    end

  
  always @(posedge clk or negedge rst_n) begin //FSM 
        if (!rst_n) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    
  always @(posedge clk or negedge rst_n) begin //Synch write
        if (!rst_n) begin
            
            for (int i = 0; i < MEM_SIZE; i++) begin
                mem[i] <= '0;
            end
        end
        else if (current_state == WRITE && !ce_n && !we_n && addr_one_hot[addr]) begin
            
            mem[addr] <= data_in;
        end
    end

   
    always_comb begin //Asych rd operation
        if (current_state == READ && !ce_n && !re_n && addr_one_hot[addr]) begin
           
            data_out = mem[addr];
        end
        else begin
            data_out = '0; 
        end
    end

endmodule
endmodule
