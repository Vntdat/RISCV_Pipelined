module ex_ff (
		input logic i_clk, i_reset_ex, i_enable_ex,
		input logic pc_sel_ex, rd_wren_ex, inst_vld_ex, mem_wren_ex,
		input logic [1:0] wb_sel_ex,
		input logic [31:0] alu_data,
		input logic [31:0] rs2_data_ex,
		input logic [31:0] immgen_ex,
		input logic [31:0] instr_ex,
		input logic [31:0] pc_ex,
		input logic [31:0] pc_four_ex,
		input logic [3:0] lsu_op_ex,
		
		output logic pc_sel_mem, rd_wren_mem, inst_vld_mem, mem_wren_mem,
		output logic [1:0] wb_sel_mem,
		output logic [31:0] alu_data_mem,
		output logic [31:0] rs2_data_mem,
		output logic [31:0] immgen_mem,
		output logic [31:0] instr_mem,
		output logic [31:0] pc_mem,
		output logic [31:0] pc_four_mem,
		output logic [3:0] lsu_op_mem
);
		always_ff @(posedge i_clk) begin
			if (!i_reset_ex) begin
				pc_sel_mem		<= 1'b0;
				rd_wren_mem 	<= 1'b0;
				inst_vld_mem 	<= 1'b1;
				mem_wren_mem	<= 1'b0;
				wb_sel_mem		<= 2'b00;
				alu_data_mem	<= 32'h0;
				rs2_data_mem	<= 32'h0;
				immgen_mem		<= 32'h0;
				instr_mem		<= 32'h0000_0013;
				pc_mem			<= 32'h0;
				pc_four_mem		<= 32'h0;
				lsu_op_mem 		<= 4'b0000;
				end
			else if (i_enable_ex) begin
				pc_sel_mem		<= pc_sel_ex;
				rd_wren_mem 	<= rd_wren_ex;
				inst_vld_mem 	<= inst_vld_ex;
				mem_wren_mem	<= mem_wren_ex;
				wb_sel_mem		<= wb_sel_ex;
				alu_data_mem	<=	alu_data;
				rs2_data_mem	<= rs2_data_ex;
				immgen_mem		<=	immgen_ex;
				instr_mem		<=	instr_ex;
				pc_mem			<= pc_ex;
				pc_four_mem		<= pc_four_ex;
				lsu_op_mem		<= lsu_op_ex;
				end
			end
endmodule
