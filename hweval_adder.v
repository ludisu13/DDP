`timescale 1ns / 1ps

module hweval_adder(
    input   clk,
    input   resetn,
    output  data_ok
);

    reg          start;
    reg          subtract;
    reg  [512:0] in_a;
    reg  [512:0] in_b;
    wire [513:0] result;
    wire         done;
       
    // Instantiate the adder    
    adder dut (
        .clk      (clk     ),
        .resetn   (resetn  ),
        .start    (start   ),
        .subtract (subtract),
        .in_a     (in_a    ),
        .in_b     (in_b    ),
        .result   (result  ),
        .done     (done    ));

    // Assign values to the inputs to the adder
    always @(posedge(clk))
    begin
        if (resetn==0)
        begin
            in_a     <= 0;
            in_b     <= 0;
            start    <= 0;
            subtract <= 0;
        end
        else
        begin
            in_a     <= in_a     ^ {513{1'b1}};
            in_b     <= in_b     ^ {513{1'b1}};
            start    <= start    ^ 1;
            subtract <= subtract ^ 1;
        end
    end
    
    assign data_ok = done & (result=={514{1'b0}});
    
endmodule


