module op2_mux (input [1:0] select, input [7:0] register, immediate, output reg [7:0] result);

always@(*)
begin
	case(select)
	2'b00: result = register;
	2'b01: result = immediate;
	2'b10: result = 8'b00000001;
	default: result = 8'b00000010;
	endcase	
end

endmodule
