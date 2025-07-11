module sram_tb;
  // Parameters matching the DUT
  parameter ADDR_WIDTH = 8;
  parameter DATA_WIDTH = 8;
  parameter MEM_SIZE = 1<<ADDR_WIDTH;
  parameter CLK_PERIOD = 10;

  // Testbench signals
  logic clk;
  logic reset_n;
  logic chip_enable_n;
  logic write_enable_n;
  logic read_enable_n;
  logic [ADDR_WIDTH-1:0] address;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;

  // Instantiate the DUT
  sram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_SIZE(MEM_SIZE)
  ) dut (
    .clk(clk),
    .reset_n(reset_n),
    .chip_enable_n(chip_enable_n),
    .write_enable_n(write_enable_n),
    .read_enable_n(read_enable_n),
    .address(address),
    .data_in(data_in),
    .data_out(data_out)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // VCD generation
  initial begin
    $dumpfile("dump.vcd"); // Specify the VCD file name
    $dumpvars(0, sram_tb); // Dump all variables in the testbench hierarchy
  end

  // Test stimulus
  initial begin
    // Initialize signals
    reset_n = 1;
    chip_enable_n = 1;
    write_enable_n = 1;
    read_enable_n = 1;
    address = 0;
    data_in = 0;

    // Test Case 1: Reset Test
    $display("Test Case 1: Reset Test");
    reset_n = 0;
    repeat(2) @(posedge clk);
    reset_n = 1;
    @(posedge clk);
    assert(dut.current_state == dut.IDLE) else $error("Reset failed: Not in IDLE state");

    // Test Case 2: Write to valid address
    $display("Test Case 2: Write to valid address");
    chip_enable_n = 0;
    write_enable_n = 0;
    read_enable_n = 1;
    address = 8'h00;
    data_in = 8'hAA;
    @(posedge clk);
    @(posedge clk);
    chip_enable_n = 1;
    write_enable_n = 1;
    @(posedge clk);
    assert(dut.mem[0] == 8'hAA) else $error("Write failed at address 0");

    // Test Case 3: Read from valid address
    $display("Test Case 3: Read from valid address");
    chip_enable_n = 0;
    write_enable_n = 1;
    read_enable_n = 0;
    address = 8'h00;
    @(posedge clk);
    @(posedge clk);
    assert(data_out == 8'hAA) else $error("Read failed at address 0");
    chip_enable_n = 1;
    read_enable_n = 1;
    @(posedge clk);

    // Test Case 4: Write to max address
    $display("Test Case 4: Write to max address");
    chip_enable_n = 0;
    write_enable_n = 0;
    read_enable_n = 1;
    address = MEM_SIZE-1;
    data_in = 8'hFF;
    @(posedge clk);
    @(posedge clk);
    chip_enable_n = 1;
    write_enable_n = 1;
    @(posedge clk);
    assert(dut.mem[MEM_SIZE-1] == 8'hFF) else $error("Write failed at max address");

    // Test Case 5: Read from max address
    $display("Test Case 5: Read from max address");
    chip_enable_n = 0;
    write_enable_n = 1;
    read_enable_n = 0;
    address = MEM_SIZE-1;
    @(posedge clk);
    @(posedge clk);
    assert(data_out == 8'hFF) else $error("Read failed at max address");
    chip_enable_n = 1;
    read_enable_n = 1;
    @(posedge clk);

    // Test Case 6: Chip disabled during write
    $display("Test Case 6: Chip disabled during write");
    chip_enable_n = 1;
    write_enable_n = 0;
    read_enable_n = 1;
    address = 8'h10;
    data_in = 8'hBB;
    @(posedge clk);
    @(posedge clk);
    assert(dut.mem[8'h10] != 8'hBB) else $error("Write occurred when chip disabled");

    // Test Case 7: Chip disabled during read
    $display("Test Case 7: Chip disabled during read");
    chip_enable_n = 1;
    write_enable_n = 1;
    read_enable_n = 0;
    address = 8'h00;
    @(posedge clk);
    @(posedge clk);
    assert(data_out == 8'h00) else $error("Read occurred when chip disabled");

    // Test Case 8: Simultaneous read and write (invalid case)
    $display("Test Case 8: Simultaneous read and write");
    chip_enable_n = 0;
    write_enable_n = 0;
    read_enable_n = 0;
    address = 8'h20;
    data_in = 8'hCC;
    @(posedge clk);
    @(posedge clk);
    assert(dut.current_state == dut.IDLE) else $error("Invalid state for simultaneous read/write");
    chip_enable_n = 1;
    write_enable_n = 1;
    read_enable_n = 1;
    @(posedge clk);

    // Test Case 9: Write with invalid address
    $display("Test Case 9: Write with invalid address");
    chip_enable_n = 0;
    write_enable_n = 0;
    read_enable_n = 1;
    address = MEM_SIZE; // Out of bounds
    data_in = 8'hDD;
    @(posedge clk);
    @(posedge clk);
    assert(dut.mem[0] != 8'hDD) else $error("Write occurred with invalid address");
    chip_enable_n = 1;
    write_enable_n = 1;
    @(posedge clk);

    // Test Case 10: Read with invalid address
    $display("Test Case 10: Read with invalid address");
    chip_enable_n = 0;
    write_enable_n = 1;
    read_enable_n = 0;
    address = MEM_SIZE; // Out of bounds
    @(posedge clk);
    @(posedge clk);
    assert(data_out == 8'h00) else $error("Read occurred with invalid address");
    chip_enable_n = 1;
    read_enable_n = 1;
    @(posedge clk);

    // Test Case 11: Rapid state transitions
    $display("Test Case 11: Rapid state transitions");
    chip_enable_n = 0;
    // Write
    write_enable_n = 0;
    read_enable_n = 1;
    address = 8'h30;
    data_in = 8'hEE;
    @(posedge clk);
    // Immediate read
    write_enable_n = 1;
    read_enable_n = 0;
    @(posedge clk);
    assert(data_out == 8'hEE) else $error("Rapid transition read failed");
    chip_enable_n = 1;
    read_enable_n = 1;
    @(posedge clk);

    // Test Case 12: Reset during operation
    $display("Test Case 12: Reset during operation");
    chip_enable_n = 0;
    write_enable_n = 0;
    read_enable_n = 1;
    address = 8'h40;
    data_in = 8'h11;
    @(posedge clk);
    reset_n = 0;
    @(posedge clk);
    reset_n = 1;
    @(posedge clk);
    assert(dut.current_state == dut.IDLE) else $error("Reset during operation failed");

    $display("All tests completed!");
    $finish;
  end

  // Monitor
  initial begin
    $monitor("Time=%0t rst_n=%b ce_n=%b we_n=%b re_n=%b addr=%h data_in=%h data_out=%h state=%s",
             $time, reset_n, chip_enable_n, write_enable_n, read_enable_n,
             address, data_in, data_out, dut.current_state.name());
  end
  initial 
    begin
 		$dumpfile("dump.vcd");
 		$dumpvars;
		end
endmodule
