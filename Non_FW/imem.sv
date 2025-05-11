module imem (
    input  logic [31:0] i_addr,
    output logic [31:0] o_inst
);
    logic [31:0] memory [0:16383];
    initial begin
        $readmemh("/home/cpa/ca111/pl-test/02_test/isa.mem", memory);  // file imem.mem chứa mã lệnh hex
    end
    always_comb begin
        o_inst = memory[i_addr[15:2]];
    end

endmodule
