module id_ff (
		input logic i_clk, i_reset_id, i_enable_id,
		input logic pc_sel, rd_wren, inst_vld, br_un, opa_sel, opb_sel, mem_wren,
		input logic [3:0] alu_op,
		input logic [1:0] wb_sel,
		input logic [31:0] rs1_data,
		input logic [31:0] rs2_data,
		input logic [31:0] immgen,
		input logic [31:0] instr_id,
		input logic [31:0] pc_id,
		input logic [31:0] pc_four_id,
		input logic [3:0] lsu_op,
		
		output logic pc_sel_ex, rd_wren_ex, inst_vld_ex, br_un_ex, opa_sel_ex, opb_sel_ex, mem_wren_ex,
		output logic [3:0] alu_op_ex,
		output logic [1:0] wb_sel_ex,
		output logic [31:0] rs1_data_ex,
		output logic [31:0] rs2_data_ex,
		output logic [31:0] immgen_ex,
		output logic [31:0] instr_ex,
		output logic [31:0] pc_ex,
		output logic [31:0] pc_four_ex,
		output logic [3:0] lsu_op_ex
);
		always_ff @(posedge i_clk) begin
			if (!i_reset_id) begin
				pc_sel_ex		<= 1'b0;
				rd_wren_ex 		<= 1'b0;
				inst_vld_ex 	<= 1'b0;
				br_un_ex			<= 1'b0;
				opa_sel_ex 		<= 1'b0;
				opb_sel_ex 		<= 1'b0;
				mem_wren_ex		<= 1'b0;
				alu_op_ex		<= 4'b0000;
				wb_sel_ex		<= 2'b00;
				rs1_data_ex		<= 32'h0;
				rs2_data_ex		<= 32'h0;
				immgen_ex		<= 32'h0;
				instr_ex			<= 32'h0000_0013;
				pc_ex				<= 32'h0;
				pc_four_ex		<= 32'h0;
				lsu_op_ex		<= 4'b0000;
			end
		else if (i_enable_id) begin
				pc_sel_ex		<= pc_sel;
				rd_wren_ex 		<= rd_wren;
				inst_vld_ex 	<= inst_vld;
				br_un_ex			<= br_un;
				opa_sel_ex 		<= opa_sel;
				opb_sel_ex 		<= opb_sel;
				mem_wren_ex		<= mem_wren;
				alu_op_ex		<= alu_op;
				wb_sel_ex		<= wb_sel;
				rs1_data_ex		<= rs1_data;
				rs2_data_ex		<= rs2_data;
				immgen_ex		<= immgen;
				instr_ex			<= instr_id;
				pc_ex				<= pc_id;
				pc_four_ex		<= pc_four_id;
				lsu_op_ex		<= lsu_op;
			end
		end
endmodule
