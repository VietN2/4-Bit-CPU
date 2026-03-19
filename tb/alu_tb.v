`timescale 1ns/1ps

module alu_tb;

    reg  [3:0] A;
    reg  [3:0] B;
    reg  [2:0] OP;

    wire [3:0] RESULT;
    wire ZERO;
    wire CARRY;

    // Instantiate the ALU
    alu uut (
        .A(A),
        .B(B),
        .OP(OP),
        .RESULT(RESULT),
        .ZERO(ZERO),
        .CARRY(CARRY)
    );

    initial begin
        // Test ADD
        A = 4'd3; B = 4'd2; OP = 3'b000;
        #10;

        // Test SUB
        A = 4'd5; B = 4'd3; OP = 3'b001;
        #10;

        // Test AND
        A = 4'd6; B = 4'd3; OP = 3'b010;
        #10;

        // Test OR
        A = 4'd6; B = 4'd3; OP = 3'b011;
        #10;

        // Test XOR
        A = 4'd6; B = 4'd3; OP = 3'b100;
        #10;

        // Test NOT
        A = 4'd6; OP = 3'b101;
        #10;

        // Test ZERO flag
        A = 4'd2; B = 4'd2; OP = 3'b001;
        #10;

        $finish;
    end

endmodule