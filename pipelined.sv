module pipelined (
    // Inputs
    input logic i_clk,
    input logic i_reset,
    input logic [31:0] i_io_sw,

    // Outputs
    output logic [31:0] o_io_lcd,
    output logic [31:0] o_io_ledg,
    output logic [31:0] o_io_ledr,
    output logic [6:0] o_io_hex0,
    output logic [6:0] o_io_hex1,
    output logic [6:0] o_io_hex2,
    output logic [6:0] o_io_hex3,
    output logic [6:0] o_io_hex4,
    output logic [6:0] o_io_hex5,
    output logic [6:0] o_io_hex6,
    output logic [6:0] o_io_hex7,
    // Debugging signal
    output logic [31:0] o_pc_debug
);

    // Wire declarations
    logic pc_sel, pc_sel_wb, pc_sel_ex, pc_sel_mem;
	 logic br_equal, br_less, br_un, br_un_ex;
	 logic opa_sel, opb_sel, opa_sel_ex, opb_sel_ex;
	 logic [3:0] alu_op, alu_op_ex;
	 logic  mem_wren, mem_wren_ex,mem_wren_mem;
	 logic wb_sel, wb_sel_ex, wb_sel_mem;
	 logic [31:0] alu_data_mem, alu_data; 
	 logic [31:0] pc_next;
	 logic [31:0] pc, pc_id, pc_ex, pc_mem;
	 logic [31:0] pc_four, pc_four_id, pc_four_ex,pc_four_mem;
	 logic [31:0] instr, instr_id,instr_ex, instr_wb, instr_mem;
	 logic [3:0] lsu_op, lsu_op_ex, lsu_op_mem;
	//STAGE IF
//////////////////////////////////////////////////////////////////////	
	   assign pc_four = pc + 32'd4;
    //mux-PC source
    always_comb begin
        if (pc_sel_wb) begin //PC4-0 and ALU_DATA-1
            pc_next = alu_data_mem;
        end
        else begin
            pc_next = pc_four;
        end
    end
    //PC counter
    always_ff @(posedge i_clk) begin
        if (i_reset) pc <= 32'h0;
        else pc <= pc_next;
    end
    // Memory unit (for fetching instructions)
	imem imem (
	.i_addr (pc),
	.o_inst (instr)
	);
	
	// IF_FF
	if_ff if_ff(
		.i_clk (i_clk),
		.instr (instr),
		.pc (pc),
		.pc_four (pc_four),
		.instr_id (instr_id),
		.pc_id (pc_id),
		.pc_four_id (pc_four_id)
	);
/////////////////////////////////////////////////////////////////////
//STAGE ID
/////////////////////////////////////////////////////////////////////
    //regfile
    regfile regfile (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_rs1_addr     (instr_id [19:15]),
        .i_rs2_addr     (instr_id [24:20]),
        .i_rd_addr      (instr_wb [11:7]),
        .i_rd_data      (wb_data),
        .i_rd_wren      (rd_wren_wb),
        .o_rs1_data     (rs1_data),
        .o_rs2_data     (rs2_data)
);
	    immgen immgen (
        .i_inst (instr_id),
        .o_imm (immgen)
);
    // Control unit
    controlunit controlunit (
        .i_instr    (instr_id),
        .br_less    (br_less),
        .br_equal   (br_equal),
        .pc_sel     (pc_sel),
        .rd_wren    (rd_wren),
        .br_un      (br_un),
        .opa_sel    (opa_sel),
        .opb_sel    (opb_sel),
        .mem_wren   (mem_wren),
        .alu_op     (alu_op),
        .wb_sel     (wb_sel),
		  .lsu_op      (lsu_op)
    );
		// ID_FF
		id_ff id_ff(
			//in
        .pc_sel     (pc_sel),
        .rd_wren    (rd_wren),
        .br_un      (br_un),
        .opa_sel    (opa_sel),
        .opb_sel    (opb_sel),
        .mem_wren   (mem_wren),
        .alu_op     (alu_op),
        .wb_sel     (wb_sel),
		  .lsu_op     (lsu_op),
		  .rs1_data	  (rs1_data),
		  .rs2_data		(rs2_data),
		  .immgen		(immgen),
		  .instr_id		(instr_id),
		  .pc_id			(pc_id),
		  .pc_four_id	(pc_four_id),
		  //out
		  .pc_sel_ex     (pc_sel_ex),
        .rd_wren_ex    (rd_wren_ex),
        .br_un_ex      (br_un_ex),
        .opa_sel_ex    (opa_sel_ex),
        .opb_sel_ex    (opb_sel_ex),
        .mem_wren_ex   (mem_wren_ex),
        .alu_op_ex     (alu_op_ex),
        .wb_sel_ex     (wb_sel_ex),
		  .lsu_op_ex     (lsu_op_ex),
		  .rs1_data_ex	  (rs1_data_ex),
		  .rs2_data_ex		(rs2_data_ex),
		  .immgen_ex		(immgen_ex),
		  .instr_ex		(instr_ex),
		  .pc_ex			(pc_ex),
		  .pc_four_ex	(pc_four_ex)
		);
		
/////////////////////////////////////////////////////////////////////
//STAGE EX
/////////////////////////////////////////////////////////////////////
    // Branch comparison logic
    brc brc (
        .i_rs1_data      (rs1_data_ex),
        .i_rs2_data      (rs2_data_ex),
        .i_br_un         (br_un_ex),
        .o_br_less       (br_less),
        .o_br_equal      (br_equal)
    );
	     // ALU operation
    alu alu (
        .i_op_a      (operand_a),
        .i_op_b      (operand_b),
        .i_alu_op    (alu_op_ex),
        .o_alu_data  (alu_data)
    );

    // Operand selection
    mux2_1_32bit opa (
        .a (rs1_data_ex),
        .b (pc_ex),
        .s (opa_sel_ex),
        .y (operand_a)
    );

    mux2_1_32bit opb (
        .a (rs2_data_ex),
        .b (immgen_ex),
        .s (opb_sel_ex),
        .y (operand_b)
    );
	 //EX_FF
	 ex_ff ex_ff (
			//in
				.pc_sel_ex			(pc_sel_ex),
				.rd_wren_ex 		(rd_wren_ex),
				.mem_wren_ex		(mem_wren_ex),
				.wb_sel_ex			(wb_sel_ex),
				.alu_data			(alu_data),
				.rs2_data_ex		(rs2_data_ex),
				.immgen_ex			(immgen_ex),
				.instr_ex			(instr_ex),
				.pc_ex				(pc_ex),
				.pc_four_ex			(pc_four_ex),
				.lsu_op_ex 			(lsu_op_ex),
			//out
				.pc_sel_mem			(pc_sel_mem),
				.rd_wren_mem 		(rd_wren_mem),
				.mem_wren_mem		(mem_wren_mem),
				.wb_sel_mem			(wb_sel_mem),
				.alu_data_mem		(alu_data_mem),
				.rs2_data_mem		(rs2_data_mem),
				.immgen_mem			(immgen_mem),
				.instr_mem			(instr_mem),
				.pc_mem				(pc_mem),
				.pc_four_mem		(pc_four_mem),
				.lsu_op_mem 		(lsu_op_mem),
	 );
/////////////////////////////////////////////////////////////////////////
//STAGE MEM
/////////////////////////////////////////////////////////////////////////
    // LSU (Load/Store Unit)
    lsu lsu (
		.i_clk 	(i_clk),
		.i_reset (i_reset),
		.i_addr 	(alu_data_mem),
		.i_wdata (rs2_data_mem),
		.i_bmask (lsu_op_mem),
		.i_wren	(mem_wren_mem),
		.o_rdata (ld_data),
       /* .o_io_ledr     (o_io_ledr_mem),
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
		  */
    );
		//MEM_FF
			mem_ff mem_ff (
			//in
				.pc_sel_mem		(pc_sel_mem),
				.rd_wren_mem	(rd_wren_mem),
				//.inst_vld_mem  (inst_vld_mem),
				.wb_sel_mem		(wb_sel_mem),		
				.ld_data			(ld_data),
				.alu_data_mem	(alu_data_mem),
				.immgen_mem		(immgen_mem),
				.instr_mem		(instr_mem),
				.pc_four_mem	(pc_four_mem),
				.pc_mem			(pc_mem),
				/*
        .o_io_ledr_mem     (o_io_ledr_mem),
        .o_io_ledg_mem     (o_io_ledg_mem),
        .o_io_hex0_mem     (o_io_hex0_mem),
        .o_io_hex1_mem     (o_io_hex1_mem),
        .o_io_hex2_mem     (o_io_hex2_mem),
        .o_io_hex3_mem     (o_io_hex3_mem),
        .o_io_hex4_mem     (o_io_hex4_mem),
        .o_io_hex5_mem     (o_io_hex5_mem),
        .o_io_hex6_mem     (o_io_hex6_mem),
        .o_io_hex7_mem     (o_io_hex7_mem),
        .o_io_lcd_mem      (o_io_lcd_mem),
        .i_io_sw       (i_io_sw),
		  */
			//out
				.pc_sel_wb		(pc_sel_wb),
				.rd_wren_wb		(rd_wren_wb),
				//.inst_vld_wb  (inst_vld_wb),
				.wb_sel_wb		(wb_sel_wb),		
				.ld_data_wb		(ld_data_wb),
				.alu_data_wb	(alu_data_wb),
				.immgen_wb		(immgen_wb),
				.instr_wb		(instr_wb),
				.pc_four_wb		(pc_four_wb),
				.pc_wb			(pc_wb),
				/*
        .o_io_ledr     (o_io_ledr),
        .o_io_ledg    (o_io_ledg),
        .o_io_hex0     (o_io_hex0),
        .o_io_hex1    (o_io_hex1),
        .o_io_hex2     (o_io_hex2),
        .o_io_hex3    (o_io_hex3),
        .o_io_hex4     (o_io_hex4),
        .o_io_hex5     (o_io_hex5),
        .o_io_hex6     (o_io_hex6),
        .o_io_hex7    (o_io_hex7),
        .o_io_lcd     (o_io_lcd),
        .i_io_sw_wb       (i_io_sw_wb),
		  */
			);
//////////////////////////////////////////////////////////////////////////////
//STAGE WB
//////////////////////////////////////////////////////////////////////////////
    // Write-back multiplexer
    mux4_1_32bit wb (
	    .a (alu_data_wb),
	    .b (ld_data_wb),
	    .c (pc_four_wb),
        .d (immgen_wb),
        .s (wb_sel_wb),
        .y (wb_data)
    );

endmodule
