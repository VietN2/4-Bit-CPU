    module control_unit(
        input clk,
        input rst,
        input [3:0] opcode,
        input zero_flag,
        input carry_flag,

        output reg pc_inc,
        output reg pc_load,
        output reg ir_load,
        output reg acc_wr,
        output reg mem_wr,
        output reg [2:0] alu_op,
        output reg [1:0] acc_src,
        output reg halt
    );

        localparam FETCH = 2'b00;
        localparam DECODE = 2'b01;
        localparam EXECUTE = 2'b10;

        reg [1:0] state;

        always @(posedge clk) begin
            if (rst) begin
                state <= FETCH;
                    pc_inc   <= 1'b0;
                    pc_load  <= 1'b0;
                    ir_load  <= 1'b0;
                    acc_wr   <= 1'b0;
                    mem_wr   <= 1'b0;
                    alu_op   <= 3'b000;
                    acc_src  <= 2'b00;
                    halt     <= 1'b0;
            end
            else begin
                case (state)
                    FETCH: begin
                        ir_load <= 1'b1;  
                        pc_inc <= 1'b1;  
                        state <= DECODE;
                    end
                    DECODE: begin
                        ir_load <= 1'b0;
                        pc_inc  <= 1'b0;
                        state   <= EXECUTE;
                    end
                    EXECUTE: begin
                        pc_inc   <= 1'b0;
                        pc_load  <= 1'b0;
                        acc_wr   <= 1'b0;
                        mem_wr   <= 1'b0;
                        alu_op   <= 3'b000;
                        halt     <= 1'b0;

                        case (opcode)
                            4'b0000: begin

                            end

                            4'b0001: begin
                                acc_wr  <= 1'b1;    
                                acc_src <= 2'b00;  
                            end

                            4'b0011: begin
                                 mem_wr <= 1'b1;
                            end

                            4'b1110: begin
                                halt <= 1'b1;
                            end

                            4'b0010: begin // LDA
                                acc_wr  <= 1'b1;
                                acc_src <= 2'b01;   // 01 = from memory
                            end

                            4'b0100: begin // ADD
                                acc_wr  <= 1'b1;
                                acc_src <= 2'b10;   // 10 = from ALU
                                alu_op  <= 3'b000;
                            end

                            4'b0101: begin // SUB
                                acc_wr  <= 1'b1;
                                acc_src <= 2'b10;
                                alu_op  <= 3'b001;
                            end

                            4'b1010: begin // JMP
                                pc_load <= 1'b1;
                            end

                            4'b1011: begin // JZ
                                if (zero_flag)
                                    pc_load <= 1'b1;
                            end

                            4'b1100: begin // JC
                                if (carry_flag)
                                    pc_load <= 1'b1;
                            end

                            4'b0110: begin // AND
                                acc_wr  <= 1'b1;
                                acc_src <= 2'b10;
                                alu_op  <= 3'b010;
                            end

                            4'b0111: begin // OR
                                acc_wr  <= 1'b1;
                                acc_src <= 2'b10;
                                alu_op  <= 3'b011;
                            end

                            4'b1000: begin // XOR
                                acc_wr  <= 1'b1;
                                acc_src <= 2'b10;
                                alu_op  <= 3'b100;
                            end

                            4'b1001: begin // NOT
                                acc_wr  <= 1'b1;
                                acc_src <= 2'b10;
                                alu_op  <= 3'b101;
                            end

                        endcase
                        state <= FETCH;
                    end
                endcase
            end
            end
    endmodule