module tb_pipeline_processor;
    reg clk = 0;
    reg reset = 1;
    pipeline_processor uut(.clk(clk), .reset(reset));

    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, tb_pipeline_processor);

        // Initialize Instruction Memory with:
        // ADD R1, R2, R3
        // SUB R4, R1, R3
        // LOAD R5, 0(R2)
        uut.instr_mem[0] = 32'b000000_00010_00011_00001_00000_100000; // ADD R1,R2,R3
        uut.instr_mem[1] = 32'b000000_00001_00011_00100_00000_100010; // SUB R4,R1,R3
        uut.instr_mem[2] = 32'b100011_00010_00101_0000000000000000;   // LOAD R5,0(R2)

        // Initialize registers
        uut.reg_file[2] = 10; // R2
        uut.reg_file[3] = 5;  // R3

        #5 reset = 0;
        #100 $finish;
    end

    always #5 clk = ~clk;
endmodule
