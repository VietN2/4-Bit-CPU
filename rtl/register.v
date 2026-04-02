// ============================================================
// register.v
// Parameterized synchronous register with async reset
//
// Parameters:
//   WIDTH - data width in bits (default 4)
//
// Ports:
//   clk      - clock (rising edge triggered)
//   rst      - asynchronous reset, active high
//   load     - load enable: captures data_in when high
//   data_in  - input data (WIDTH bits)
//   data_out - registered output (WIDTH bits)
//
// Usage examples:
//   register #(.WIDTH(4)) acc_reg (...);  // 4-bit accumulator
//   register #(.WIDTH(8)) ir_reg  (...);  // 8-bit instruction register
// ============================================================

module register #(
    parameter WIDTH = 4
)(
    input                  clk,
    input                  rst,
    input                  load,
    input      [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= {WIDTH{1'b0}};   // zero all bits on reset
        else if (load)
            data_out <= data_in;          // capture input only when load is asserted
        // else: hold current value (implicit in sequential always block)
    end

endmodule
