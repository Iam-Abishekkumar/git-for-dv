      "fifo_overflow": begin
        for (int i = 0; i <= DEPTH; i++) write(8'hB0 + i);       // one write too many
        if (!full) begin errors++; $display("ERROR: full not set"); end
        for (int i = 0; i < DEPTH; i++) read_check(8'hB0 + i);  // the extra write must be dropped
        if (!empty) begin errors++; $display("ERROR: extra write was not dropped"); end
      end
