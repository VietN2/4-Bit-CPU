`timescale 1ns/1ps

module cpu_top(
    input clk,
    input rst,
    output [3:0] out_data,
    output halt
);

wire [7:0] instruction;
wire [3:0] opcode, operand;
wire [3:0] acc_out, alu_result, mem_data;
wire [3:0] pc_addr;
wire alu_zero, alu_carry;
reg  zero_flag, carry_flag;
wire pc_inc, pc_load, ir_load, acc_wr, mem_wr;
wire [2:0] alu_op;
wire [1:0] acc_src;
wire [3:0] acc_data;
wire [7:0] ir_out;

assign opcode  = ir_out[7:4];
assign operand = ir_out[3:0];

reg [7:0] ir_reg;
assign ir_out = ir_reg;

always @(posedge clk) begin
    if (rst)
        ir_reg <= 8'b0;
    else if (ir_load)
        ir_reg <= instruction;
end

// Flags register: latch the ALU flags only at the moment an ALU result
// is written to ACC (acc_wr with acc_src = ALU). Without this, JZ/JC
// would sample the ALU's live combinational flags, which by branch time
// are computed from the branch's own operand address - not the result
// of the last arithmetic instruction. Loads (LDI/LDA) leave flags alone.
always @(posedge clk) begin
    if (rst) begin
        zero_flag  <= 1'b0;
        carry_flag <= 1'b0;
    end
    else if (acc_wr && acc_src == 2'b10) begin
        zero_flag  <= alu_zero;
        carry_flag <= alu_carry;
    end
end

// Mux for ACC input
assign acc_data = (acc_src == 2'b00) ? operand :
                  (acc_src == 2'b01) ? mem_data :
                                       alu_result;

// Output
assign out_data = acc_out;



// --- Module Instantiations ---

pc my_pc(
    .clk(clk),
    .rst(rst),
    .inc(pc_inc),
    .load(pc_load),
    .addr_in(operand),
    .addr_out(pc_addr)
);

alu my_alu(
    .A(acc_out),
    .B(mem_data),
    .OP(alu_op),
    .RESULT(alu_result),
    .ZERO(alu_zero),
    .CARRY(alu_carry)
);

register my_register(
    .clk(clk),
    .rst(rst),
    .wr_en(acc_wr),
    .data_in(acc_data),
    .data_out(acc_out)
);

instr_mem my_instr_mem(
    .addr(pc_addr),
    .data(instruction)
);

data_mem my_data_mem(
    .clk(clk), 
    .addr(operand),
    .data_in(acc_out),
    .wr_en(mem_wr),
    .data_out(mem_data)
);

control_unit my_control_unit(
    .clk(clk), 
    .rst(rst),
    .opcode(opcode),
    .zero_flag(zero_flag),
    .carry_flag(carry_flag),
    .pc_inc(pc_inc),
    .pc_load(pc_load),
    .ir_load(ir_load),
    .acc_wr(acc_wr),
    .mem_wr(mem_wr),
    .alu_op(alu_op),
    .acc_src(acc_src),
    .halt(halt)
);

endmodule