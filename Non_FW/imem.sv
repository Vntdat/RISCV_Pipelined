module imem (
    input  logic [31:0] i_addr,
    output logic [31:0] o_inst
);
    logic [31:0] memory [0:31];
    initial begin
        $readmemh("E:/BKHCM/HK 242/CTMT/code/Mile3/peipelineds/isa.mem", memory);  // file imem.mem chứa mã lệnh hex
    end
    always_comb begin
        o_inst = memory[i_addr[6:2]];
    end

endmodule

