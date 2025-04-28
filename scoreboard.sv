module scoreboard(
  input  logic [31:0]  o_pc_debug,
  input  logic [31:0]  o_io_ledr,
  input  logic [31:0]  o_io_ledg,
  input  logic [ 6:0]  o_io_hex0,
  input  logic [ 6:0]  o_io_hex1,
  input  logic [ 6:0]  o_io_hex2,
  input  logic [ 6:0]  o_io_hex3,
  input  logic [ 6:0]  o_io_hex4,
  input  logic [ 6:0]  o_io_hex5,
  input  logic [ 6:0]  o_io_hex6,
  input  logic [ 6:0]  o_io_hex7,
  input  logic [31:0]  o_io_lcd ,
  input  logic [31:0]  i_io_sw  ,
  input  logic         o_insn_vld,
  input  logic         o_mispred ,
  input  logic         o_ctrl    ,
  input logic i_clk,
  input logic i_reset
);

  real num_cycle;
  real num_insn;
  real num_ctrl;
  real num_mispred;
  real ipc;
  real misprd_rate;

  initial begin
    $display("\nPIPELINE - ISA tests\n");
  end

  always @(negedge i_clk) begin
    if (!i_reset) begin
      num_cycle   <= '0;
      num_insn    <= '0;
      num_ctrl    <= '0;
      num_mispred <= '0;
    end
    else begin
      num_cycle   <=              num_cycle   + 1;
      num_insn    <= o_insn_vld ? num_insn    + 1 : num_insn;
      num_ctrl    <= o_ctrl     ? num_ctrl    + 1 : num_ctrl;
      num_mispred <= o_mispred  ? num_mispred + 1 : num_mispred;
    end

    if (o_insn_vld && (o_pc_debug == 32'h14)) $write("%s", o_io_ledr[7:0]);
    if (o_insn_vld && (o_pc_debug == 32'h1c)) begin
      $display("\nResult\n");
      $display("IPC = %1.2f", num_insn/num_cycle);

      if (num_cycle != 0)
        $display("IPC          =  %1.2f", num_insn/num_cycle);
      else
        $display("IPC          = N/A");

      if (num_ctrl != 0)
        $display("Mispred Rate = %2.2f %", num_mispred/num_ctrl*100);
      else
        $display("Mispred Rate = N/A");

      $display("\nEND of ISA tests\n");
      $finish;
    end
  end

endmodule : scoreboard
