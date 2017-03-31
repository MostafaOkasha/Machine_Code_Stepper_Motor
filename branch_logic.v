module branch_logic (input [7:0] register0, output reg branch);

always @(*)
begin
	///////////////////////
	if (register0 == 0) branch = 1'b1;
	else branch  = 1'b0;
end


endmodule
