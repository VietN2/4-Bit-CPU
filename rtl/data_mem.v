module data_mem(
    input clk,
    input [3:0] addr,
    input [3:0] data_in,
    input wr_en,
    output [3:0] data_out

);

reg [3:0] mem [0:15];

assign data_out = mem[addr];

always @(posedge clk) begin
    if (wr_en)
        mem[addr] <= data_in;
end

endmodule