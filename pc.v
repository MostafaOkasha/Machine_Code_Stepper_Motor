module pc (input clk, reset_n, branch, increment, input [7:0] newpc, output reg [7:0] pc);

parameter RESET_LOCATION = 8'h00;

always @(posedge clk)
begin
	/////////////////////////////////////////
	if (!reset_n) pc <= RESET_LOCATION;
	
	else if (branch) pc <= newpc;  //if branch is high then our pc will be set to a new location
	
	else if (increment) pc = pc + 8'b00000001; //increment the pc if the increment signal is high
	
	end		
endmodule
