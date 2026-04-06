`timescale 1ns/1ps

module alu_tb;

    reg  [3:0] A;
    reg  [3:0] B;
    reg  [2:0] OP;

    wire [3:0] RESULT;
    wire ZERO;
    wire CARRY;

    alu out (
        .A(A),
        .B(B),
        .OP(OP),
        .RESULT(RESULT),
        .ZERO(ZERO),
        .CARRY(CARRY)
    );

    initial begin
        $display("Time  A     B     OP   RESULT ZERO CARRY");
        $monitor("%0t   %b  %b  %b   %b    %b    %b", $time, A, B, OP, RESULT, ZERO, CARRY);

        A = 4'd3; B = 4'd2; OP = 3'b000;
        #10;

        A = 4'd5; B = 4'd3; OP = 3'b001;
        #10;

        A = 4'd6; B = 4'd3; OP = 3'b010;
        #10;

        A = 4'd6; B = 4'd3; OP = 3'b011;
        #10;

        A = 4'd6; B = 4'd3; OP = 3'b100;
        #10;

        A = 4'd6; B = 4'd0; OP = 3'b101;
        #10;

        A = 4'd2; B = 4'd2; OP = 3'b001;
        #10;
        
        // Carry on ADD: 15+1 = 16 → overflow
        A = 4'd15; B = 4'd1; OP = 3'b000;
        #10;

        // Borrow on SUB: 2-5 → underflow
        A = 4'd2; B = 4'd5; OP = 3'b001;
        #10;

        // Zero on ADD: 0+0
        A = 4'd0; B = 4'd0; OP = 3'b000;
        #10;
        
        $finish;
    end

endmodule