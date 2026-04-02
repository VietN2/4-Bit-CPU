// ============================================================
// pc.v
// 4-bit Program Counter
//
// Behavior (priority order):
//   1. rst  = 1 → reset to 0x0 (highest priority)
//   2. load = 1 → jump to data_in (used by JMP / JZ / JC)
//   3. inc  = 1 → increment PC by 1 (normal fetch advance)
//   4. else     → hold current value
//
// Ports:
//   clk      - clock (rising edge triggered)
//   rst      - asynchronous reset, active high
//   inc      - increment enable (assert during FETCH)
//   load     - load enable (assert during EXECUTE for jumps)
//   data_in  - jump target address (4 bits) — wire to IR[3:0] in cpu_top
//   pc_out   - current PC value (4 bits)
//   overflow - pulses high for one cycle when PC wraps 15 → 0
//              use this in testbenches to catch runaway programs
//
// NOTE: load and inc must never both be asserted simultaneously.
//       load takes priority, but the control unit FSM should
//       guarantee mutual exclusion between the two.
// ============================================================

module pc (
    input        clk,
    input        rst,
    input        inc,
    input        load,
    input  [3:0] data_in,
    output reg       overflow,
    output reg [3:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out   <= 4'b0000;
            overflow <= 1'b0;
        end
        else if (load) begin
            pc_out   <= data_in;
            overflow <= 1'b0;
        end
        else if (inc) begin
            overflow <= (pc_out == 4'b1111);   // flag wraps before they happen
            pc_out   <= pc_out + 4'b0001;
        end
        else begin
            overflow <= 1'b0;                  // clear when not incrementing
        end
    end

    // Simulation-only: warn in transcript if PC wraps without a HLT
    `ifdef SIMULATION
    always @(posedge clk) begin
        if (inc && (pc_out == 4'b1111))
            $display("WARNING [pc.v]: PC overflow at time %0t — did your program end with HLT?", $time);
    end
    `endif

endmodule
