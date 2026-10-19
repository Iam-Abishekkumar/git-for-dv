#!/usr/bin/env bash
# make_edits.sh: type the code for you, so the exercises can focus on Git.
#
#   ../make_edits.sh overflow   add the fifo_overflow test AND a debug $display to fifo_dv  (exercise 9)
#   ../make_edits.sh wip        a half-finished edit to the testbench                       (exercise 10)

set -euo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
R="$ROOT/work/fifo_dv"
[ -d "$R/.git" ] || { echo "Clone the project first (exercise 2): work/fifo_dv/ not found."; exit 1; }
TB="$R/tb/tb_fifo.sv"

insert() {  # before|after  match-text  block-file
  awk -v where="$1" -v pat="$2" -v blk="$3" '
    index($0, pat) && !done && where == "before" { while ((getline l < blk) > 0) print l; done = 1 }
    { print }
    index($0, pat) && !done && where == "after"  { while ((getline l < blk) > 0) print l; done = 1 }
  ' "$TB" > "$TB.new" && mv "$TB.new" "$TB"
}

case "${1:-}" in
  overflow)
    grep -q '"fifo_overflow"' "$TB" && { echo "The fifo_overflow test is already there."; exit 0; }
    insert before '      default: begin' "$ROOT/lab/blocks/overflow.sv"
    insert after  '@(negedge clk); wr_en = 1; wdata = d;' "$ROOT/lab/blocks/debug.sv"
    echo fifo_overflow >> "$R/tests/testlist"
    echo "Added the fifo_overflow test to tb/tb_fifo.sv and tests/testlist,"
    echo "plus a debug \$display in the write task that must NOT be committed."
    ;;
  wip)
    grep -q 'n_dropped' "$TB" && { echo "The half-finished edit is already there."; exit 0; }
    insert after '  int         errors = 0;' "$ROOT/lab/blocks/wip.sv"
    echo "Added a half-finished coverage counter to tb/tb_fifo.sv."
    ;;
  *)
    sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
