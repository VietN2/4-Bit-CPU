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
        $dumpfile("waveforms/cpu_wave.vcd");
        $dumpvars(0, cpu_tb);
        clk = 0;
        rst = 1;        // hold reset
        #20;
        rst = 0;        // release reset, CPU starts

        wait (halt);    // wait until CPU halts
        #10;

        $display("Output: %b (%0d)", out_data, out_data);
        $finish;
    end

endmodule