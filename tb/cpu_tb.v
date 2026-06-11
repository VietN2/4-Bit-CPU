`timescale 1ns/1ps

module cpu_tb;

    reg clk = 0;
    reg rst;
    wire [3:0] out_data;
    wire halt;

    reg [8*40-1:0] prog;    // program filename from +prog=
    reg [3:0] expected;

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

        // Default run is test1 expecting 5. Override with:
        //   vvp cpu_test +prog=programs/test2.mem +expect=0000
        if (!$value$plusargs("expect=%b", expected))
            expected = 4'b0101;

        rst = 1;        // hold reset
        #20;

        // Load the program while still in reset, AFTER instr_mem's own
        // initial $readmemb has run, so the override can't be clobbered
        if ($value$plusargs("prog=%s", prog))
            $readmemb(prog, uut.my_instr_mem.mem);

        rst = 0;        // release reset, CPU starts

        wait (halt);    // wait until CPU halts
        #10;

        $display("Output: %b (%0d)", out_data, out_data);
        if (out_data !== expected)
            $display("FAIL: expected %b, got %b", expected, out_data);
        else
            $display("PASS");
        $finish;
    end

    // Watchdog: the wait(halt) above couples the testbench to the DUT
    // behaving correctly. If halt never asserts (broken branch, missing
    // HLT), kill the sim instead of hanging forever.
    initial begin
        #5000;
        $display("TIMEOUT: halt never asserted after 5000ns");
        $finish;
    end

endmodule
