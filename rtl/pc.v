module pc (
    input        clk,
    input        rst,
    input        inc,
    input        load,
    input  [3:0] addr_in,
    output reg [3:0] addr_out
);

    always @(posedge clk) begin
        if (rst)
            addr_out <= 4'b0000;
        else if (load)
            addr_out <= addr_in;
        else if (inc)
            addr_out <= addr_out + 4'b0001;
    end

endmodule