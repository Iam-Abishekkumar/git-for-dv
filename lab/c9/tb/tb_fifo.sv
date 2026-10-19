// Self-checking FIFO testbench. Pick a test with +TEST=<name>
module tb_fifo;
  localparam int DEPTH = 4;
  logic       clk = 0, rst_n = 0, wr_en = 0, rd_en = 0;
  logic [7:0] wdata = 0, rdata;
  logic       full, empty;
  int         errors = 0;
  reg [8*32-1:0] test;  // test name from +TEST=

  fifo #(.DEPTH(DEPTH)) dut (.clk(clk), .rst_n(rst_n), .wr_en(wr_en), .wdata(wdata),
                             .rd_en(rd_en), .rdata(rdata), .full(full), .empty(empty));
  always #5 clk = ~clk;

  task automatic write(input logic [7:0] d);
    @(negedge clk); wr_en = 1; wdata = d;
    @(negedge clk); wr_en = 0;
  endtask

  task automatic read_check(input logic [7:0] exp);
    @(negedge clk);
    if (rdata !== exp) begin errors++; $display("ERROR: exp=%h act=%h", exp, rdata); end
    rd_en = 1; @(negedge clk); rd_en = 0;
  endtask

  initial begin
    if ($test$plusargs("WAVES")) begin $dumpfile("sim/waves.vcd"); $dumpvars(0, tb_fifo); end
    if (!$value$plusargs("TEST=%s", test)) test = "fifo_basic";
    repeat (2) @(negedge clk); rst_n = 1;
    case (test)
      "fifo_basic": begin
        write(8'h11); write(8'h22);
        read_check(8'h11); read_check(8'h22);
      end
      "fifo_full": begin
        for (int i = 0; i < DEPTH; i++) write(8'hA0 + i);
        if (!full) begin errors++; $display("ERROR: full not set after %0d writes", DEPTH); end
        for (int i = 0; i < DEPTH; i++) read_check(8'hA0 + i);
      end
      "fifo_empty": begin
        if (!empty) begin errors++; $display("ERROR: empty not set after reset"); end
        write(8'h5A); read_check(8'h5A);
        @(negedge clk);
        if (!empty) begin errors++; $display("ERROR: empty not set after last read"); end
      end
      default: begin errors++; $display("ERROR: unknown test %0s", test); end
    endcase
    if (errors == 0) $display("TEST PASSED: %0s", test);
    else             $display("TEST FAILED: %0s (%0d errors)", test, errors);
    $finish;
  end
endmodule
