module immediate_extractor (input [7:0] instruction, input [1:0] select, output reg [7:0] immediate);

always@(*)
	begin
		case(select)   //{{15{summation[z][31]}}, summation[z][31:15]}
			2'b00: immediate = {{5'b00000},{instruction[4:2]}};
			2'b01: immediate = {{4'b0000},{instruction[3:0]}};
			2'b10: immediate = {{3{instruction[4]}}, {instruction[4:0]}};
			default: immediate = 8'b00000000;
		endcase
	end

endmodule
