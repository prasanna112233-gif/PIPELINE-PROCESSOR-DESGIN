module pipeline_processor(
    input clk,
    input reset
);

    reg [31:0] pc;
    reg [31:0] instr_mem [0:15];  // Instruction Memory
    reg [31:0] data_mem [0:15];   // Data Memory
    reg [31:0] reg_file [0:7];    // 8 Registers

    // Pipeline registers
    reg [31:0] IF_ID_instr;
    reg [31:0] ID_EX_instr;
    reg [31:0] ID_EX_reg1, ID_EX_reg2;
    reg [4:0]  ID_EX_rd;
    reg [31:0] EX_WB_result;
    reg [4:0]  EX_WB_rd;
    reg        EX_WB_wen;

    // Fetch Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            IF_ID_instr <= 0;
        end else begin
            IF_ID_instr <= instr_mem[pc >> 2];
            pc <= pc + 4;
        end
    end

    // Decode Stage
    wire [5:0] opcode = IF_ID_instr[31:26];
    wire [4:0] rs = IF_ID_instr[25:21];
    wire [4:0] rt = IF_ID_instr[20:16];
    wire [4:0] rd = IF_ID_instr[15:11];
    wire [15:0] imm = IF_ID_instr[15:0];
    wire [31:0] imm_ext = {{16{imm[15]}}, imm};

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_EX_instr <= 0;
            ID_EX_reg1 <= 0;
            ID_EX_reg2 <= 0;
            ID_EX_rd <= 0;
        end else begin
            ID_EX_instr <= IF_ID_instr;
            ID_EX_reg1 <= reg_file[rs];
            ID_EX_reg2 <= reg_file[rt];
            ID_EX_rd <= rd;
        end
    end

    // Execute Stage
    reg [31:0] alu_result;
    reg        wen;

    always @(*) begin
        case (ID_EX_instr[31:26])
            6'b000000: begin // R-type (ADD/SUB)
                case (ID_EX_instr[5:0])
                    6'b100000: alu_result = ID_EX_reg1 + ID_EX_reg2; // ADD
                    6'b100010: alu_result = ID_EX_reg1 - ID_EX_reg2; // SUB
                    default:   alu_result = 0;
                endcase
                wen = 1;
            end
            6'b100011: begin // LOAD
                alu_result = data_mem[ID_EX_reg1 >> 2];
                wen = 1;
            end
            default: begin
                alu_result = 0;
                wen = 0;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_WB_result <= 0;
            EX_WB_rd <= 0;
            EX_WB_wen <= 0;
        end else begin
            EX_WB_result <= alu_result;
            EX_WB_rd <= ID_EX_rd;
            EX_WB_wen <= wen;
        end
    end

    // Write Back Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
        end else if (EX_WB_wen) begin
            reg_file[EX_WB_rd] <= EX_WB_result;
        end
    end

endmodule

