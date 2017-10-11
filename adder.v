`timescale 1ns / 1ps

module adder(
    input  wire         clk,
    input  wire         resetn,
    input  wire         start,
    input  wire         subtract,
    input  wire [513:0] in_a,
    input  wire [513:0] in_b,    
    output wire [514:0] result,
    output wire         done    
    );

    reg [514:0] reg_result;

    // What impact does a 513-bit add operation have on the critical path of the design? 
    
    always @(posedge clk)
        if (resetn==1'b0)
            reg_result <= 0;
        else
            reg_result = in_a + in_b;

    assign result = reg_result;
    assign done = 1'b1;

endmodule
