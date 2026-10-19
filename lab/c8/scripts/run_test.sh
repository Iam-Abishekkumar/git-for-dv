#!/usr/bin/env bash
# Usage: scripts/run_test.sh <test> [seed]
# Exit codes: 0 = pass, 1 = fail, 125 = could not build (git bisect skips it)
set -u
test=${1:?usage: run_test.sh <test> [seed]}
seed=${2:-1}
root=$(git rev-parse --show-toplevel) && cd "$root" || exit 125
mkdir -p sim/build sim/logs
log="sim/logs/${test}_${seed}.log"
rev=$(git describe --always --dirty --tags)
printf 'commit: %s\ntest: %s  seed: %s\n' "$rev" "$test" "$seed" > "$log"
iverilog -V 2>&1 | head -n 1 >> "$log"
iverilog -g2012 -o sim/build/simv rtl/fifo.sv tb/tb_fifo.sv >> "$log" 2>&1 || { echo "BUILD FAILED ($rev)"; exit 125; }
vvp -n sim/build/simv +TEST="$test" +SEED="$seed" ${EXTRA:-} >> "$log" 2>&1
if grep -q "TEST PASSED" "$log"; then
  echo "PASS  $test  @ $rev"; exit 0
else
  echo "FAIL  $test  @ $rev   (log: $log)"; exit 1
fi
