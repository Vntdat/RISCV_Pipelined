module hdu (
		input logic 		 i_clk,
		input logic 		 i_reset,
		input logic [31:0] instr_id,
		input logic [31:0] instr_ex,
		input logic [31:0] instr_mem,
		input logic [31:0] instr_wb,
		input logic rd_wren_ex, rd_wren_mem, rd_wren_wb, pc_sel_ex,
		
		output logic i_reset_pc, i_enable_pc,
		output logic i_reset_if, i_enable_if,	
		output logic i_reset_id, i_enable_id,
		output logic i_reset_ex, i_enable_ex,
		output logic i_reset_mem, i_enable_mem
);
		logic [4:0] rs1_addr_id, rs2_addr_id, rd_addr_ex, rd_addr_mem, rd_addr_wb;
		logic data_hazard, is_rs2_addr_id, control_hazard;
		//xác định thanh ghi rs2 được dùng
		assign is_rs2_addr_id = ((instr_id[6:0] == 7'b0110011) ||   // R-type
										 (instr_id[6:0] == 7'b0100011) ||   // S-type
										 (instr_id[6:0] == 7'b1100011));    // B-type
		////
		assign rs1_addr_id = instr_id[19:15];
		assign rs2_addr_id = instr_id[24:20];
		assign rd_addr_ex	 = instr_ex[11:7];
		assign rd_addr_mem = instr_mem[11:7];
		assign rd_addr_wb	 = instr_wb[11:7];
		
		//Xác định data_hazard
		assign data_hazard = (
			 ((rd_wren_ex)  && (rd_addr_ex  != 5'h0) && ((rd_addr_ex  == rs1_addr_id) || ((rd_addr_ex  == rs2_addr_id) && is_rs2_addr_id))) ||
			 ((rd_wren_mem) && (rd_addr_mem != 5'h0) && ((rd_addr_mem == rs1_addr_id) || ((rd_addr_mem == rs2_addr_id) && is_rs2_addr_id))) ||
			 ((rd_wren_wb)  && (rd_addr_wb  != 5'h0) && ((rd_addr_wb  == rs1_addr_id) || ((rd_addr_wb  == rs2_addr_id) && is_rs2_addr_id)))
		);
	
		assign control_hazard = pc_sel_ex;
		

		//khởi tạo tín hiệu mặc định
		always_comb begin
			i_reset_ex		= i_reset;
			i_reset_id		= i_reset;
			i_reset_if		= i_reset;
			i_reset_mem		= i_reset;
			i_reset_pc		= i_reset;
			i_enable_ex		= 1'b1;
			i_enable_id		= 1'b1;
			i_enable_if		= 1'b1;
			i_enable_mem	= 1'b1;
			i_enable_pc		= 1'b1;

		//phát hiện data_hazard
			if (control_hazard) begin
					i_reset_if = 1'b0;
					i_reset_id = 1'b0;
			end 
			else if (data_hazard) begin
					i_reset_id  = 1'b0;
					i_enable_if = 1'b0;
					i_enable_pc = 1'b0;
			end

			else begin
					i_reset_ex		= i_reset;
					i_reset_id		= i_reset;
					i_reset_if		= i_reset;
					i_reset_mem		= i_reset;
					i_reset_pc		= i_reset;
					i_enable_ex		= 1'b1;
					i_enable_id		= 1'b1;
					i_enable_if		= 1'b1;
					i_enable_mem	= 1'b1;
					i_enable_pc		= 1'b1;				
			end
		end
endmodule
