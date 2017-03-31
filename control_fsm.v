module control_fsm (
	input clk, reset_n,
	// Status inputs
	input br, brz, addi, subi, sr0, srh0, clr, mov, mova, movr, movrhs, pause,
	input delay_done,
	input temp_is_positive, temp_is_negative, temp_is_zero,
	input register0_is_zero,
	// Control signal outputs
	output reg write_reg_file,
	output reg result_mux_select,
	output reg [1:0] op1_mux_select, op2_mux_select,
	output reg start_delay_counter, enable_delay_counter,
	output reg commit_branch, increment_pc,
	output reg alu_add_sub, alu_set_low, alu_set_high,
	output reg load_temp_register, increment_temp_register, decrement_temp_register,
	output reg [1:0] select_immediate,
	output reg [1:0] select_write_address
);
parameter RESET=5'b00000, FETCH=5'b00001, DECODE=5'b00010,
			BR=5'b00011, BRZ=5'b00100, ADDI=5'b00101, SUBI=5'b00110, SR0=5'b00111,
			SRH0=5'b01000, CLR=5'b01001, MOV=5'b01010, MOVA=5'b01011,
			MOVR=5'b01100, MOVRHS=5'b01101, PAUSE=5'b01110, MOVR_STAGE2=5'b01111,
			MOVR_DELAY=5'b10000, MOVRHS_STAGE2=5'b10001, MOVRHS_DELAY=5'b10010,
			PAUSE_DELAY=5'b10011;

reg [5:0] state;
reg [5:0] next_state_logic; // NOT REALLY A REGISTER!!!

// Next state logic
always @(*) begin
	next_state_logic = RESET;
	
	if (!reset_n) next_state_logic = RESET;
	else
	begin
	case(state)
		RESET:
			next_state_logic = FETCH;
		FETCH:
			next_state_logic = DECODE;
		DECODE: begin
			if (pause) 
				next_state_logic = PAUSE;
			else if (movrhs)
				next_state_logic = MOVRHS;
			else if (movr)
				next_state_logic = MOVR;
			else if (brz)
				next_state_logic = BRZ;
			else if (br)
				next_state_logic = BR;
			else if (clr)
				next_state_logic = CLR;
			else if (srh0)
				next_state_logic = SRH0;
			else if (sr0)
				next_state_logic = SR0;
			else if (mov)
				next_state_logic = MOV;
			else if (subi)
				next_state_logic = SUBI;
			else if (addi)
				next_state_logic = ADDI;
			else if (mova)
				next_state_logic = MOVA;
		end
		
		BR:
			next_state_logic = FETCH;
		BRZ:
			next_state_logic = FETCH;
		ADDI:
			next_state_logic = FETCH;
		SUBI:
			next_state_logic = FETCH;
		SR0:
			next_state_logic = FETCH;
		SRH0:
			next_state_logic = FETCH;
		CLR:
			next_state_logic = FETCH;
		MOV:
			next_state_logic = FETCH;
		MOVA:
			next_state_logic = FETCH;
		MOVR:
			next_state_logic = MOVR_STAGE2;
		MOVRHS:
			next_state_logic = MOVRHS_STAGE2;
		PAUSE:
			next_state_logic = PAUSE_DELAY;
		MOVR_STAGE2: begin
			if(temp_is_zero)
				next_state_logic = FETCH;
			else
				next_state_logic = MOVR_DELAY;
		end
		MOVR_DELAY: begin
			if (delay_done)
				next_state_logic = MOVR_STAGE2;
			else
				next_state_logic = MOVR_DELAY;
		end
		MOVRHS_STAGE2: begin
			if(temp_is_zero)
				next_state_logic = FETCH;
			else
				next_state_logic = MOVRHS_DELAY;
		end
		MOVRHS_DELAY: begin
			if(delay_done)
				next_state_logic = MOVRHS_STAGE2;
			else
				next_state_logic = MOVRHS_DELAY;
		end
		PAUSE_DELAY: begin
			if(delay_done)
				next_state_logic = FETCH;
			else
				next_state_logic = PAUSE_DELAY;
		end
		default:
		next_state_logic = RESET;
	endcase
	end
end
			

// State register
always @(posedge clk) begin
		state<= next_state_logic;
end

// Output logic
always @(*) begin

	write_reg_file = 1'b0;
	result_mux_select = 1'b0;
	op1_mux_select = 2'b00;
	op2_mux_select = 2'b00;
	start_delay_counter = 1'b0;
	enable_delay_counter = 1'b0;
	commit_branch = 1'b0;
	increment_pc = 1'b0;
	alu_add_sub = 1'b0;
	alu_set_low = 1'b0;
	alu_set_high = 1'b0;
	load_temp_register = 1'b0;
	increment_temp_register = 1'b0;
	decrement_temp_register = 1'b0;
	select_immediate = 2'b00;
	select_write_address = 2'b00;
	
	case(state)

		BR: begin
			select_immediate = 2'b10;
			op1_mux_select = 2'b00;
			op2_mux_select = 2'b01;
			alu_add_sub = 1'b0;
			commit_branch = 1'b1;
		end
		
		BRZ: begin
			if (register0_is_zero) begin //same as br
				select_immediate = 2'b10;
				op1_mux_select = 2'b00;
				op2_mux_select = 2'b01;
				alu_add_sub = 1'b0;
				commit_branch = 1'b1;
			end else
				increment_pc = 1'b1;
		end
		
		ADDI: begin
			select_immediate = 2'b00;
			op1_mux_select = 2'b01;
			op2_mux_select = 2'b01;
			alu_add_sub = 1'b0;
			result_mux_select = 1'b1;
			write_reg_file = 1'b1;
			select_write_address = 2'b01;
			increment_pc = 1'b1;
		end
		
		SUBI: begin
			select_immediate = 2'b00;
			op1_mux_select = 2'b01;
			op2_mux_select = 2'b01;
			alu_add_sub = 1'b1;
			result_mux_select = 1'b1;
			write_reg_file = 1'b1;
			select_write_address = 2'b01;
			increment_pc = 1'b1;
		end
		
		SR0: begin
			select_immediate = 2'b01; 
			op1_mux_select = 2'b11;
			op2_mux_select = 2'b01;
			alu_set_low = 1'b1;
			result_mux_select = 1'b1;
			write_reg_file = 1'b1;
			select_write_address = 2'b00;
			increment_pc = 1'b1;
		end
		
		SRH0: begin //same as sr0 but high
			select_immediate = 2'b01; 
			op1_mux_select = 2'b11;
			op2_mux_select = 2'b01;
			alu_set_high = 1'b1;
			result_mux_select = 1'b1;
			write_reg_file = 1'b1;
			select_write_address = 2'b00;
			increment_pc = 1'b1;
		end
		
		CLR: begin // r0 <= 0
			result_mux_select = 1'b0;
			write_reg_file = 1'b1;
			select_write_address = 2'b01;
			increment_pc = 1'b1;
		end
		
		MOV:  begin
			select_immediate = 2'b11; 
			op1_mux_select = 2'b01;
			op2_mux_select = 2'b01;
			alu_add_sub = 1'b0;
			result_mux_select = 1'b1;
			write_reg_file = 1'b1;
			select_write_address = 2'b10;
			increment_pc = 1'b1;
		end
		
		MOVA: select_immediate = 2'b00;
		
		MOVR:
			load_temp_register = 1'b1;
		MOVRHS:
			load_temp_register = 1'b1;
			
		PAUSE: begin
			start_delay_counter = 1'b1;
		end
		
		MOVR_STAGE2: begin
			if (temp_is_zero)
					increment_pc = 1'b1;
			else begin
				if(temp_is_positive) begin
					decrement_temp_register = 1'b1;
					op1_mux_select = 2'b10;
					op2_mux_select = 2'b11;
					alu_add_sub = 1'b0;
					result_mux_select = 1'b1;
					select_write_address = 2'b11;
					write_reg_file = 1'b1;
				end else begin
					increment_temp_register = 1'b1;
					op1_mux_select = 2'b10;
					op2_mux_select = 2'b11;
					alu_add_sub = 1'b1;
					result_mux_select = 1'b1;
					select_write_address = 2'b11;
					write_reg_file = 1'b1;
				end
				start_delay_counter = 1'b1;
			end
		end
		
		MOVR_DELAY:
			enable_delay_counter = 1'b1;
		
		MOVRHS_STAGE2: begin
			if (temp_is_zero)
					increment_pc = 1'b1;
			else begin
				if(temp_is_positive) begin
					decrement_temp_register = 1'b1;
					op1_mux_select = 2'b10;
					op2_mux_select = 2'b10;
					alu_add_sub = 1'b0;
					result_mux_select = 1'b1;
					select_write_address = 2'b11;
					write_reg_file = 1'b1;
				end else begin
					increment_temp_register = 1'b1;
					op1_mux_select = 2'b10;
					op2_mux_select = 2'b10;
					alu_add_sub = 1'b1;
					result_mux_select = 1'b1;
					select_write_address = 2'b11;
					write_reg_file = 1'b1;
				end
				start_delay_counter = 1'b1;
			end
		end
		MOVRHS_DELAY:
			enable_delay_counter = 1'b1;
			
		PAUSE_DELAY:
		begin
			enable_delay_counter = 1'b1;
		if (delay_done)
			increment_pc = 1'b1;
		end
		
		default: result_mux_select = 1'b0;

	endcase
end
endmodule
