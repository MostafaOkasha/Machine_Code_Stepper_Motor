module result_mux (input select_result, input [7:0] alu_result, output reg [7:0] result);

always @(*)
begin
	///////////////////////
	case (select_result)
	default: result = 8'b00000000;
	1'b1: result = alu_result;
	endcase
end

endmodule
