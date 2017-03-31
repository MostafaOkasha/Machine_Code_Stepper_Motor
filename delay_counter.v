module delay_counter (input clk, reset_n, start, enable, input [7:0] delay, output done);

parameter BASIC_PERIOD=19'd500000;

//14 bits, required to hold 100000 decimal
// for 1 MHz clock, the 1/100 second is 10,000 clock cycle, that is 14'd10000.
reg [7:0] downcounter;
reg [19:0] timer;

always @(posedge clk)
begin
if (!reset_n)
begin
	timer<=20'b0000000000000000000; //14'b00000000000000;
	downcounter<=8'b00000001;
	done <=8'b00000000;
end
///////////
else if (start==1'b1)
begin
	timer<=20'd0;
	downcounter<=delay;
	done<=0;
end
/////////////
else if (enable==1'b1)
begin
	if (timer<BASIC_PERIOD) timer<=timer+20'd1;//14'b00000000000001;
else

begin
	downcounter<=downcounter-8'b1;
	if (downcounter == 0) done <= 1'b1;
	timer<=20'd0;//14'b00000000000000
end

end

end

endmodule
