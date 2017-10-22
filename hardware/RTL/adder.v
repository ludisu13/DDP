`timescale 1ns / 1ps

module adder #(parameter ADDER_SIZE=64)(
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
                        STATE_TWO   = 3'b010,//add 
                        STATE_THREE = 3'b011;//done 
    reg [511:0] reg_result;
    reg [511:0] operand_a;
    reg [511:0] operand_b;
    wire [ADDER_SIZE:0] add_result;
    wire mux_sel;
    wire [511:0] op_b_sel;

    wire [1:0]hack;
    reg carry;
    wire [511:0] shifted;
    wire end_carry;
    assign op_b_sel=(subtract==1'b1) ? (~in_b):in_b;
    assign mux_sel=(state==STATE_ONE) ? 1'b1:1'b0;// 1 selects input 0 selects shifted
    assign done=(state==STATE_THREE) ? 1'b1 :1'b0;// 1 selects shifted resuld 0 selects add result
    assign end_carry= (subtract==1'b1) ? carry^1:carry;
    assign hack=in_a[512]+in_b[512]+(end_carry); 
    assign shifted=reg_result>>ADDER_SIZE;
    always @(posedge clk) begin
        if (resetn==1'b0 )begin
            reg_result <= 0;
	        operand_a <=0;
            operand_b <=0;
            carry <=0;
        end
        else begin
            operand_a<= (mux_sel==1'b1)? in_a:operand_a>>ADDER_SIZE; 		
            operand_b<= (mux_sel==1'b1)? op_b_sel:operand_b>>ADDER_SIZE; 
            reg_result <= {add_result[ADDER_SIZE-1:0],shifted[512-1-ADDER_SIZE:0]};
            carry <= (state==STATE_ONE) ? subtract:add_result[ADDER_SIZE];
	    if(state==STATE_THREE)
	    	$display("result %0x ",result);
        end
    end  		
    assign result = {hack[1:0],reg_result};
    assign add_result = ( operand_a[ADDER_SIZE-1:0]+operand_b[ADDER_SIZE-1:0]+carry);//save power

                    
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
                                next_state <= (cnt<((512/ADDER_SIZE)))?  STATE_TWO:STATE_THREE;//?latch 
                            end
                       STATE_THREE:
                            begin
                                next_state <=  STATE_IDLE; 
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
    
