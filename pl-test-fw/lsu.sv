module lsu (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [31:0] i_addr,
    input  logic [31:0] i_wdata,
    input  logic [3:0]  i_bmask,
    input  logic        i_wren,
    output logic [31:0] o_rdata,

    // I/O Ports
    output logic [31:0] o_io_ledr,    // Red LEDs
    output logic [31:0] o_io_ledg,    // Green LEDs
    output logic [6:0]  o_io_hex0,    // 7-seg 0
    output logic [6:0]  o_io_hex1,    // 7-seg 1
    output logic [6:0]  o_io_hex2,    // 7-seg 2
    output logic [6:0]  o_io_hex3,    // 7-seg 3
    output logic [6:0]  o_io_hex4,    // 7-seg 4
    output logic [6:0]  o_io_hex5,    // 7-seg 5
    output logic [6:0]  o_io_hex6,    // 7-seg 6
    output logic [6:0]  o_io_hex7,    // 7-seg 7
    output logic [31:0] o_io_lcd,     // LCD Control
    input  logic [31:0] i_io_sw       // Switches
);

    // Memory and I/O Registers
    logic [31:0] data_memory [0:511];  // 2KB RAM (512 words)
    logic [31:0] lcd_reg;              // LCD Control Register
    logic [31:0] ledr_reg;             // Red LEDs
    logic [31:0] ledg_reg;             // Green LEDs
    logic [6:0]  hex_reg [0:7];        // Individual 7-segment registers

    // Address Decoding
    logic is_ram_access;    // RAM access
    logic is_ledr_access;   // Red LEDs access
    logic is_ledg_access;   // Green LEDs access
    logic is_hex0_3_access; // HEX0-3 access
    logic is_hex4_7_access; // HEX4-7 access
    logic is_lcd_access;    // LCD access
    logic is_sw_access;     // Switches access
    
    // Alignment check
    logic addr_misaligned;

    // Address Decoding Logic
    always_comb begin
        is_ram_access    = (i_addr[31:11] == 21'b0000_0000_0000_0000_0000_0);     // 0x0000_0000-0x0000_07FF
        is_ledr_access   = (i_addr[31:12] == 20'h10000);     // 0x1000_0000-0x1000_0FFF
        is_ledg_access   = (i_addr[31:12] == 20'h10001);     // 0x1000_1000-0x1000_1FFF
        is_hex0_3_access = (i_addr[31:12] == 20'h10002);     // 0x1000_2000-0x1000_2FFF
        is_hex4_7_access = (i_addr[31:12] == 20'h10003);     // 0x1000_3000-0x1000_3FFF
        is_lcd_access    = (i_addr[31:12] == 20'h10004);     // 0x1000_4000-0x1000_4FFF
        is_sw_access     = (i_addr[31:12] == 20'h10010);     // 0x1001_0000-0x1001_0FFF
        
        // Check for misaligned accesses
        // Word access (LW/SW) must be 4-byte aligned
        // Half-word access (LH/LHU/SH) must be 2-byte aligned
        addr_misaligned = (i_bmask[3] && i_addr[1:0] != 2'b00) ||  // LW/SW check
                          (i_bmask[2] && i_addr[0] != 1'b0);       // LH/LHU/SH check
    end

    // Read Logic
    always_comb begin
        o_rdata = 32'h0;
			if (!i_wren && !addr_misaligned) begin
            case (1'b1)
                is_ram_access: begin
                    case (i_bmask)
								 // lb
								 4'b0000: begin
									  case (i_addr[1:0])
											2'b00: o_rdata = {{24{data_memory[i_addr[10:2]][7]}},  data_memory[i_addr[10:2]][7:0]};
											2'b01: o_rdata = {{24{data_memory[i_addr[10:2]][15]}}, data_memory[i_addr[10:2]][15:8]};
											2'b10: o_rdata = {{24{data_memory[i_addr[10:2]][23]}}, data_memory[i_addr[10:2]][23:16]};
											2'b11: o_rdata = {{24{data_memory[i_addr[10:2]][31]}}, data_memory[i_addr[10:2]][31:24]};
									  endcase
								 end

								 // lbu
								 4'b0001: begin
									  case (i_addr[1:0])
											2'b00: o_rdata = {24'h0, data_memory[i_addr[10:2]][7:0]};
											2'b01: o_rdata = {24'h0, data_memory[i_addr[10:2]][15:8]};
											2'b10: o_rdata = {24'h0, data_memory[i_addr[10:2]][23:16]};
											2'b11: o_rdata = {24'h0, data_memory[i_addr[10:2]][31:24]};
									  endcase
								 end

								 // lh
								 4'b0010: begin
									  if (i_addr[1] == 1'b0)
											o_rdata = {{16{data_memory[i_addr[10:2]][15]}}, data_memory[i_addr[10:2]][15:0]};
									  else
											o_rdata = {{16{data_memory[i_addr[10:2]][31]}}, data_memory[i_addr[10:2]][31:16]};
								 end

								 // lhu
								 4'b0011: begin
									  if (i_addr[1] == 1'b0)
											o_rdata = {16'h0, data_memory[i_addr[10:2]][15:0]};
									  else
											o_rdata = {16'h0, data_memory[i_addr[10:2]][31:16]};
								 end

								 // lw
								 4'b0100: o_rdata = data_memory[i_addr[10:2]];
								 default: o_rdata = 32'h0;
							endcase
                end
                is_ledr_access:   o_rdata = ledr_reg;
                is_ledg_access:   o_rdata = ledg_reg;
                is_hex0_3_access: o_rdata = {1'b0, hex_reg[3], 1'b0, hex_reg[2], 1'b0, hex_reg[1], 1'b0, hex_reg[0]};
                is_hex4_7_access: o_rdata = {1'b0, hex_reg[7], 1'b0, hex_reg[6], 1'b0, hex_reg[5], 1'b0, hex_reg[4]};
                is_lcd_access:    o_rdata = lcd_reg;
                is_sw_access:     o_rdata = i_io_sw;
                default:          o_rdata = 32'h0;

            endcase
        end
        else if (addr_misaligned) begin
            o_rdata = 32'h0;  // Return 0 for misaligned accesses
        end
    end

    // Write Logic (Synchronous)
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            // Reset all registers
            lcd_reg <= 0;
            ledr_reg <= 0;
            ledg_reg <= 0;
            for (int i = 0; i < 8; i++) begin
                hex_reg[i] <= 0;
            end
            
            // Initialize memory if needed
            // $readmemh("mem.dump", data_memory);
        end
        else if (i_wren) begin
            case (1'b1)
                is_ram_access: begin
                    case (i_bmask)
                        // sb - store byte
                        4'b1000: 
case (i_addr[1:0]) 
2'b00: data_memory[i_addr[10:2]][7:0] <= i_wdata[7:0];
2'b01: data_memory[i_addr[10:2]][15:8] <= i_wdata[7:0];
2'b10: data_memory[i_addr[10:2]][23:16] <= i_wdata[7:0];
2'b11: data_memory[i_addr[10:2]][31:24] <= i_wdata[7:0];
endcase
                        // sh - store half-word
                        4'b1001:
case (i_addr[1:0])
                                2'b00: data_memory[i_addr[10:2]][15:0] <= i_wdata[15:0];
                            
                                2'b10: data_memory[i_addr[10:2]][31:16] <= i_wdata[15:0];
                          default: ;
endcase
                      
                        // sw - store word
                        4'b1010: data_memory[i_addr[10:2]] <= i_wdata;
                        default: ; // Ignore
                    endcase
                end
                is_ledr_access: begin
                    ledr_reg <= i_wdata;
                end
                is_ledg_access: begin
                    ledg_reg <= i_wdata;
                end
                is_hex0_3_access: begin
                    if (i_bmask[0]) hex_reg[0] <= i_wdata[6:0];
                    if (i_bmask[1]) hex_reg[1] <= i_wdata[14:8];
                    if (i_bmask[2]) hex_reg[2] <= i_wdata[22:16];
                    if (i_bmask[3]) hex_reg[3] <= i_wdata[30:24];
                end
                is_hex4_7_access: begin
                    if (i_bmask[0]) hex_reg[4] <= i_wdata[6:0];
                    if (i_bmask[1]) hex_reg[5] <= i_wdata[14:8];
                    if (i_bmask[2]) hex_reg[6] <= i_wdata[22:16];
                    if (i_bmask[3]) hex_reg[7] <= i_wdata[30:24];
                end
                is_lcd_access: begin
                    lcd_reg <= i_wdata;
                end
                default: ; // Ignore other writes
            endcase
        end
    end

    // Connect I/O Outputs
    assign o_io_ledr = ledr_reg;
    assign o_io_ledg = ledg_reg;
    assign o_io_lcd  = lcd_reg;
    assign o_io_hex0 = hex_reg[0];
    assign o_io_hex1 = hex_reg[1];
    assign o_io_hex2 = hex_reg[2];
    assign o_io_hex3 = hex_reg[3];
    assign o_io_hex4 = hex_reg[4];
    assign o_io_hex5 = hex_reg[5];
    assign o_io_hex6 = hex_reg[6];
    assign o_io_hex7 = hex_reg[7];
     
endmodule
