`timescale 1ns / 1ps

module adder #(parameter ADDER_SIZE=4)(
    input  wire         clk,
    input  wire         resetn,
    input  wire         start,
    input  wire         subtract,
    input  wire [512:0] in_a,
    input  wire [512:0] in_b,    
    output wire [513:0] result,
    output wire         done    
    );
    localparam [2:0]    STATE_IDLE  = 3'b000,//waiting for start
                        STATE_ONE   = 3'b001,//load inputs
                        STATE_TWO   = 3'b010,//load addition result to output register 
                        STATE_THREE = 3'b011,//load shifted version to output register 
                        STATE_FOUR  = 3'b100;//done   
    reg [511:0] reg_result;
    reg [511:0] operand_a;
    reg [511:0] operand_b;
    wire [ADDER_SIZE:0] add_result;

    wire mux_sel;
    wire mux_sel_result;
    assign mux_sel=(state==STATE_ONE) ? 1'b1:1'b0;// 1 selects input 0 selects shifted

    assign done=(state==STATE_FOUR) ? 1'b1 :1'b0;// 1 selects shifted resuld 0 selects add result
    assign mux_sel_result=(state==STATE_THREE) ? 1'b1:1'b0;
    wire [1:0]hack;
    assign hack=in_a[512]+in_b[512]+carry; 
    reg carry;
    always @(posedge clk) begin
        if (resetn==1'b0 )begin
            reg_result <= 0;
	    operand_a <=0;
            operand_b <=0;
            carry <=0;
        end
        else begin
            operand_a<= (mux_sel==1'b1)? in_a:((mux_sel_result==1'b1)? operand_a:(operand_a>>ADDER_SIZE)); 		
            operand_b<= (mux_sel==1'b1)? in_b:((mux_sel_result==1'b1)? operand_b:(operand_b>>ADDER_SIZE)); 
            reg_result<= (mux_sel_result==1'b0)? ({add_result[ADDER_SIZE-1:0],reg_result[(512-ADDER_SIZE)-1:0]}):(reg_result>>ADDER_SIZE);
            carry <= (mux_sel_result==1'b0)? add_result[ADDER_SIZE]:carry;
	    if(state==STATE_FOUR)
	    	$display("result %0x ",result);
        end
    end  		
    assign result = {hack[1:0],reg_result};
    assign add_result = (mux_sel_result==1'b0)?( operand_a[ADDER_SIZE-1:0]+operand_b[ADDER_SIZE-1:0]+carry):add_result;//save power

                    
    reg  [7:0] cnt;         //3-bit register
    reg  [2:0] state;       //3-bit register
    reg  [2:0] next_state;  //3-bit wire
                        //Sequential Counter logi
    always @(posedge clk)    begin
	if(next_state>=STATE_TWO && next_state<=STATE_THREE)
            begin
                   cnt <= cnt +1;
            end
	else
		cnt <= 0;
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
                                next_state <= (cnt<((512/ADDER_SIZE)*2-1))?  STATE_THREE:STATE_FOUR;//?latch 
                            end
                       STATE_THREE:
                            begin
                                next_state <=  STATE_TWO; 
                            end
                       STATE_FOUR: 
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
    
