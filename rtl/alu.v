`timescale 1ns/1ps

module alu(
    input  [3:0] A,
    input  [3:0] B,
    input  [2:0] OP,
    output reg [3:0] RESULT,
    output reg CARRY,
    output ZERO
);

assign ZERO = (RESULT == 4'b0000);

always @(*) begin
    RESULT = 4'b0000;
    CARRY  = 1'b0;

    case (OP)
        3'b000: begin // ADD
            {CARRY, RESULT} = A + B;
        end

        3'b001: begin // SUB
            {CARRY, RESULT} = A - B;
        end

        3'b010: begin // AND
            RESULT = A & B;
        end

        3'b011: begin // OR
            RESULT = A | B;
        end

        3'b100: begin // XOR
            RESULT = A ^ B;
        end

        3'b101: begin // NOT (only uses A)
            RESULT = ~A;
        end

        default: begin
            RESULT = 4'b0000;
            CARRY  = 1'b0;
        end
    endcase
end

endmodule