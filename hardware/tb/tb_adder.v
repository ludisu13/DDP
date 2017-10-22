
`timescale 1ns / 1ps

/*
Assignment:
1. Use this testbench (tb) to verify the correctness of your adder
    You can start the simulation by pressing the buttons on the left-hand: Simulation | Run Simulation
2. Implement a multi-precision adder in adder.v
3. Update the design with a two's-compliment subtractor (activate it with the 'subtract' wire)
3. Make an implementation of your design (Implementation | Run Implementation).
4. Determine the maximum clock frequency of the design (Efficient designs have a clock of around 100MHz)
5. Calculate the total execution time of one add operation
*/

`timescale 1ns / 1ps
`include "RTL/adder.v"
`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_adder();

    reg          clk;
    reg          resetn;
    reg  [512:0] in_a;
    reg  [512:0] in_b;
    reg          start;
    reg          subtract;
    reg          result_ok;
    wire [513:0] result;
    wire         done;

    adder dut (
        .clk      (clk     ),
        .resetn   (resetn  ),
        .start    (start   ),
        .subtract (subtract),
        .in_a     (in_a    ),
        .in_b     (in_b    ),
        .result   (result  ),
        .done     (done    ));

    // Generate Clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    // Initialize signals to zero
    initial begin
        in_a <= 0;
        in_b <= 0;
        subtract <= 0;
        start <= 0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end

    task perform_add;
        input [512:0] a;
        input [512:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd0;
            #`CLK_PERIOD;
            start <= 1'd0;
            wait (done==1);
            #`CLK_PERIOD;
        end
    endtask

    task perform_sub;
        input [512:0] a;
        input [512:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd1;
            #`CLK_PERIOD;
            start <= 1'd0;
            wait (done==1);
            #`CLK_PERIOD;
        end
    endtask

    initial begin
    $dumpfile("adder.vcd");
    $dumpvars;
    #`RESET_TIME

    /*************TEST ADDITION*************/
    // Check if 1+1=2
    #`CLK_PERIOD;
    perform_add(513'h1, 513'h1);
    wait (done==1);
    result_ok = (result==514'h2);

    $display("result ok first add=",result_ok);
    //Test addition with large test vectors. You can generate your own with the magma online calculator
    perform_add(513'h1d7dc5a16218f714565bc7a83ea20e4c0ecb7f8226e9dae7fdaeab517d4449c268af0a34ff2402e74a3a1350d45dc36e1ca7beb4e541105a58c3990be06f30aa9,
                513'h1f30aa08f81b00a1ee9e7d3af7cc01dba81837e2ea4a9ad9fea14343dbbd95eb2a6c44aef080d3dc83efeb5e474699aa9dbed2f56c4a26796bf7b209b7c9491a8);
    wait (done==1);//this is a TRAP, don't use for debug 
     result_ok = (result==514'h3cae6faa5a33f7b644fa44e3366e1027b6e3b765113475c1fc4fee955901dfad931b4ee3efa4d6c3ce29feaf1ba45d18ba6691aa518b36d3c4bb4b15983879c51);
    $display("result ok second add=",result_ok);
#1300;/*

    /*************TEST SUBTRACTION*************/
    //Check if 1-1=0
$display("SUBTRACTION");
    #`CLK_PERIOD;
    #`CLK_PERIOD;
    #`CLK_PERIOD;
    perform_sub(513'h1, 513'h1);
    wait (done==1);
    result_ok = (result==514'h0);
    $display("result ok first subtraction=",result_ok);

    //Test subtraction with large test vectors. You can generate your own with the magma online calculator
    perform_sub(513'h17fcaaf8fe3fd0ee41050d74d78c6087b359fc7813e749a65c4981218f36b4da932ce6e09aa0d31ad9fdddd3abd5114a71b7fd733bbca0f2261ddb7d286cf6ee1,
                513'h1f9a0c360f98cb4e0bdac0d74ee9af59daada1a769b5b2b91a54bb6a5790da2da28b78cc2d14a3f513da8adaef1e148e3a9eaecc4ca7a211bed70da87129fb6c6);
    wait (done==1);
    result_ok = (result==514'h78629ec2eea705a0352a4c9d88a2b12dd8ac5ad0aa3196ed41f4c5b737a5daacf0a16e146d8c2f25c62352f8bcb6fcbc37194ea6ef14fee06746cdd4b742fb81b);

    $display("result ok second subtraction=",result_ok);
    $finish;

    end

endmodule

