`timescale 1ns/1ps

module instr_mem (
    input [3:0] addr,
    output [7:0] data
);

reg [7:0] mem [0:15];
initial $readmemb("programs/test1.mem", mem);
assign data = mem[addr];

endmodule