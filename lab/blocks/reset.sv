      "fifo_reset": begin
        write(8'h77); rst_n = 0; @(negedge clk); rst_n = 1;
        if (!empty) begin errors++; $display("ERROR: fifo not empty after reset"); end
      end
