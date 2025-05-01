module stageif (
	input logic i_clk, i_reset, 
	input logic pc_sel_wb,
	input logic [31:0] alu_data_mem,
	
	output logic [31:0] instr,
	output logic [31:0] pc,
	output logic [31:0] pc_four
);
	logic [31:0] pc_next;

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

	endmodule