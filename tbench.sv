`define RESETPERIOD 55
//`define FINISH      100005
`define FINISH      10_000_000
`include "tlib.svh"
module tbench;

// Clock and reset generator
  logic i_clk;
  logic i_reset;

  initial tsk_clock_gen(i_clk);
  initial tsk_reset(i_reset, `RESETPERIOD);
  initial tsk_timeout(`FINISH);

// Wave dumping
  initial begin : proc_dump_wave
    $dumpfile("wave.vcd");
    $dumpvars(0, dut);
  end

  logic [31:0]  o_pc_debug;
  logic [31:0]  o_io_ledr;
  logic [31:0]  o_io_ledg;
  logic [ 6:0]  o_io_hex0;
  logic [ 6:0]  o_io_hex1;
  logic [ 6:0]  o_io_hex2;
  logic [ 6:0]  o_io_hex3;
  logic [ 6:0]  o_io_hex4;
  logic [ 6:0]  o_io_hex5;
  logic [ 6:0]  o_io_hex6;
  logic [ 6:0]  o_io_hex7;
  logic [31:0]  o_io_lcd ;
  logic [31:0]  i_io_sw  ;
  logic         o_insn_vld;
  logic         o_mispred ;
  logic         o_ctrl    ;

  driver driver (
    .*
  );

  pipelined dut (
    .*
  );

  scoreboard scoreboard (
    .*
  );

endmodule : tbench