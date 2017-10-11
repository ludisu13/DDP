`timescale 1ns / 1ps

module adder(
    input  wire         clk,
    input  wire         resetn,
    input  wire         start,
    input  wire         subtract,
    input  wire [512:0] in_a,
    input  wire [512:0] in_b,    
    output wire [513:0] result,
    output wire         done    
    );
    parameter ADDITIONS=4;
    localparam [2:0]    STATE_IDLE  = 3'b000,
                        STATE_ONE   = 3'b001, 
                        STATE_TWO = 3'b010, 
                        STATE_THREE  = 3'b011;   
    reg [513:0] reg_result;
    wire mux_sel;
    assign mux_sel=(state==STATE_TWO) ? 1'b0:1'b1;
    assign done=(state==STATE_THREE) ? 1'b1 :1'b0;

    // What impact does a 513-bit add operation have on the critical path of the design? 
    
    always @(posedge clk)
        if (resetn==1'b0)
            reg_result <= 0;
        else
            reg_result = in_a + in_b;

    assign result = reg_result;

    

                    
    reg  [4:0] cnt;         //3-bit register
    reg  [2:0] state;       //3-bit register
    reg  [2:0] next_state;  //3-bit wire
                        //Sequential Counter logi
    always @(posedge clk)    begin
        if (start==1'b0 && ((state==STATE_THREE ) || (state==STATE_IDLE)) )
            begin
                cnt <= 0;
            end
        else
            begin
               if (cnt==ADDITIONS)
                   cnt <= 0;
               else
                   cnt <= cnt +1;
            end
    end 
    
    always @(*) 
             begin
                  case (state)
                       STATE_IDLE:
                           begin
                               next_state <= (start==1'b1) ? STATE_ONE:STATE_IDLE;
                           end
                       STATE_ONE:
                           begin
                               next_state <= STATE_TWO;
                           end
                       STATE_TWO:
                            begin
                                next_state <=(cnt<ADDITIONS) ? STATE_TWO:STATE_THREE; 
                            end
                       STATE_THREE: 
                           begin
                                next_state <= STATE_IDLE;
                           end
                       default: 
                           begin
                              next_state <= STATE_IDLE;
                           end
                  endcase
             end                             
    
       //Synchronous logic to update state
     always @(posedge clk)
     begin
         if (resetn==1'b0)
         begin
             state <= 0;
         end
         else
         begin
             state <= next_state;
         end
     end
     
 
endmodule
    