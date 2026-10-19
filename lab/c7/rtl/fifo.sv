// Synchronous FIFO
module fifo #(parameter int DEPTH = 4, parameter int WIDTH = 8) (
  input  logic             clk,
  input  logic             rst_n,
  input  logic             wr_en,
  input  logic [WIDTH-1:0] wdata,
  input  logic             rd_en,
  output logic [WIDTH-1:0] rdata,
  output logic             full,
  output logic             empty
);
  logic [WIDTH-1:0]         mem [DEPTH];
  logic [$clog2(DEPTH)-1:0] wptr, rptr;
  logic [$clog2(DEPTH):0]   count;

  assign full  = (count == DEPTH-1);
  assign empty = (count == 0);
  assign rdata = mem[rptr];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wptr <= '0; rptr <= '0; count <= '0;
    end else begin
      if (wr_en && !full) begin
        mem[wptr] <= wdata;
        wptr      <= wptr + 1'b1;
      end
      if (rd_en && !empty) rptr <= rptr + 1'b1;
      case ({wr_en && !full, rd_en && !empty})
        2'b10:   count <= count + 1'b1;
        2'b01:   count <= count - 1'b1;
        default: ;
      endcase
    end
  end
endmodule
