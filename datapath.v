module datapath (input clk, reset_n,
				// Control signals
				input write_reg_file, result_mux_select,
				input [1:0] op1_mux_select, op2_mux_select,
				input start_delay_counter, enable_delay_counter,
				input commit_branch, increment_pc,                      //all done in pc
				input alu_add_sub, alu_set_low, alu_set_high,  //all done in alu
				input load_temp, increment_temp, decrement_temp,
				input [1:0] select_immediate,
				input [1:0] select_write_address,   //done
				// Status outputs
				output br, brz, addi, subi, sr0, srh0, clr, mov, mova, movr, movrhs, pause,   //all done in decoder
				output delay_done,
				output temp_is_positive, temp_is_negative, temp_is_zero,
				output register0_is_zero,
				// Motor control outputs
				output [3:0] stepper_signals
);
// The comment /*synthesis keep*/ after the declaration of a wire
// prevents Quartus from optimizing it, so that it can be observed in simulation
// It is important that the comment appear before the semicolon
wire [7:0] position /*synthesis keep*/;
wire [7:0] delay /*synthesis keep*/;
wire [7:0] register0 /*synthesis keep*/;
wire [7:0] pcwire /*synthesis keep*/;
wire [7:0] newpcwire /*synthesis keep*/;
wire [7:0] qwire /*synthesis keep*/;
wire [7:0] resmuxout /*synthesis keep*/; 
wire [1:0] writetemp /*synthesis keep*/;
wire [7:0] select0temp /*synthesis keep*/;
wire [7:0] select1temp /*synthesis keep*/;
wire [7:0] immediatetemp /*synthesis keep*/;
wire [7:0] operandtemp1 /*synthesis keep*/;
wire [7:0] operandtemp2 /*synthesis keep*/;

decoder the_decoder (        //actually done
	// Inputs
	.instruction (qwire[7:2]),
	// Outputs
	.br (br),
	.brz (brz),
	.addi (addi),
	.subi (subi),
	.sr0 (sr0),
	.srh0 (srh0),
	.clr (clr),
	.mov (mov),
	.mova (mova),
	.movr (movr),
	.movrhs (movrhs),
	.pause (pause)
);
//////////

regfile the_regfile(     //actually done
	// Inputs
	.clk (clk),
	.reset_n (reset_n),
	.write (write_reg_file),
	.data (resmuxout), 
	.select0 (qwire[1:0]),
	.select1 (qwire[3:2]),
	.wr_select (writetemp),
	// Outputs
	.selected0 (select0temp),
	.selected1 (select1temp),
	.delay (delay),
	.position (position),
	.register0 (register0)
);
//////

op1_mux the_op1_mux(       //actually done
	// Inputs
	.select (op1_mux_select),
	.pc (pcwire),
	.register (select0temp),
	.register0 (register0),
	.position (position),
	// Outputs
	.result(operandtemp1)
);
//

op2_mux the_op2_mux(        //actually done
	// Inputs
	.select (op2_mux_select),
	.register (select1temp),
	.immediate (immediatetemp),
	// Outputs
	.result (operandtemp2)
);
//

delay_counter the_delay_counter(  //actually done
	// Inputs
	.clk(clk),
	.reset_n (reset_n),
	.start (start_delay_counter),
	.enable (enable_delay_counter),
	.delay (delay),
	// Outputs
	.done (delay_done)
);
////

stepper_rom the_stepper_rom( //actually done - still need to build stuff
	// Inputs
	.address (position[2:0]),
	.clock (clk),
	// Outputs
	.q (stepper_signals)
);
/////
	
pc the_pc(                //actually DONE
	// Inputs
	.clk (clk),
	.reset_n (reset_n),
	.branch (commit_branch),
	.increment (increment_pc),
	.newpc (newpcwire),
	// Outputs
	.pc (pcwire)
);

/////

instruction_rom the_instruction_rom(         //actually DONE -- still need to build stuff 
	// Inputs
	.address (pcwire),
	.clock (clk),
	// Outputs
	.q (qwire)
);
/////

alu the_alu(      //actually done
	// Inputs
	.add_sub (alu_add_sub),
	.set_low (alu_set_low),
	.set_high (alu_set_high),
	.operanda (operandtemp1),
	.operandb (operandtemp2),
	// Outputs
	.result (newpcwire)
);
//

temp_register the_temp_register( //actually done
	// Inputs
	.clk (clk),
	.reset_n (reset_n),
	.load (load_temp),
	.increment (increment_temp),
	.decrement (decrement_temp),
	.data (select0temp),
	// Outputs
	.negative (temp_is_negative),
	.positive (temp_is_positive),
	.zero (temp_is_zero)
);
///

immediate_extractor the_immediate_extractor( //actually done
	// Inputs
	.instruction (qwire),
	.select (select_immediate),
	// Outputs
	.immediate (immediatetemp)
);
///

write_address_select the_write_address_select(     // actually done
	// Inputs
	.select (select_write_address),
	.reg_field0 (qwire[1:0]),
	.reg_field1 (qwire[3:2]),
	// Outputs
	.write_address(writetemp)
);
////

result_mux the_result_mux (         //actually DONEEEE
	.select_result (result_mux_select),
	.alu_result (newpcwire),
	.result (resmuxout)
);
//////////

branch_logic the_branch_logic(  //donee
	// Inputs
	.register0 (register0),
	// Outputs
	.branch (register0_is_zero)
);
///

endmodule
