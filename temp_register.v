module temp_register (input clk, reset_n, load, increment, decrement, input [7:0] data, output reg negative, positive, zero);

reg signed [7:0] count /*synthesis keep*/;

always@(posedge clk)
begin
	if (!reset_n) 
	count <= 0;

	else if (load) 
	count <=  data;

	else if (increment) 
	count <= count + 8'b00000001;
	
	else if (decrement) 
	count <= count - 8'b00000001;
	
	if (count < 0)
	begin 
		negative <= 1;
		positive <= 0;
		zero <= 0;
	end
	else if (count == 0)
	begin
		zero <= 1;
		negative <= 0;
		positive <= 0;
	end
	else if (count > 0)
	begin
		positive <= 1;
		negative <= 0;
		zero <= 0;
	end
end

endmodule
