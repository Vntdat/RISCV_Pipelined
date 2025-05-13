module stagemem (
		input logic i_clk, i_reset,
		input logic mem_wren_mem,
		input logic [3:0] lsu_op_mem,
		input logic [31:0] alu_data_mem, rs2_data_mem,
		input logic [31:0] i_io_sw_wb,
		
		output logic [31:0] ld_data, o_io_lcd_mem, o_io_ledg_mem, o_io_ledr_mem,
		output logic [6:0] o_io_hex0_mem, o_io_hex1_mem, o_io_hex2_mem, o_io_hex3_mem, o_io_hex4_mem, o_io_hex5_mem, o_io_hex6_mem, o_io_hex7_mem
);    // LSU (Load/Store Unit)
    lsu lsu (
		.i_clk 	(i_clk),
		.i_reset (i_reset),
		.i_addr 	(alu_data_mem),
		.i_wdata (rs2_data_mem),
		.i_bmask (lsu_op_mem),
		.i_wren	(mem_wren_mem),
		.o_rdata (ld_data),
       .o_io_ledr     (o_io_ledr_mem),
        .o_io_ledg     (o_io_ledg_mem),
        .o_io_hex0     (o_io_hex0_mem),
        .o_io_hex1     (o_io_hex1_mem),
        .o_io_hex2     (o_io_hex2_mem),
        .o_io_hex3     (o_io_hex3_mem),
        .o_io_hex4     (o_io_hex4_mem),
        .o_io_hex5     (o_io_hex5_mem),
        .o_io_hex6     (o_io_hex6_mem),
        .o_io_hex7     (o_io_hex7_mem),
        .o_io_lcd      (o_io_lcd_mem),
        .i_io_sw       (i_io_sw_wb)
		  
    );
endmodule

