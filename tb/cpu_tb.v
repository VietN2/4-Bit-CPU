`timescale 1ns/1ps

module cpu_tb;

    reg clk;
    reg rst;
    wire [3:0] out_data;
    wire halt;

    cpu_top uut(
        .clk(clk),
        .rst(rst),
        .out_data(out_data),
        .halt(halt)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        #20;
        rst = 0;

        $monitor("t=%0t pc=%h ir=%h acc=%h state=%b acc_wr=%b mem_wr=%b alu_op=%b acc_src=%b halt=%b",
                $time, uut.pc_addr, uut.ir_out, uut.acc_out,
                uut.my_control_unit.state, uut.acc_wr, uut.mem_wr,
                uut.alu_op, uut.acc_src, uut.halt);

        wait (halt);
        #10;

        $display("Output: %b (%0d)", out_data, out_data);
        $finish;
    end

endmodule