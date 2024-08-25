module CPU (
    input clk,
    input reset,
    output [18:0] pc_out,
    input [18:0] instruction,
    output [18:0] mem_address,
    input [18:0] mem_data_in,
    output [18:0] mem_data_out,
    output mem_write
);

    reg [18:0] pc;
    reg [18:0] register_file [0:15];
    reg [18:0] alu_result;
    reg [3:0] opcode;
    reg [4:0] reg1, reg2, reg3;
    reg [18:0] mem_data;
    reg mem_write_en;
    reg [18:0] encrypted_data, decrypted_data;

    function [18:0] Encrypt;
        input [18:0] data_in;
        begin
            Encrypt = data_in ^ 19'h1FFFF; 
        end
    endfunction

    function [18:0] Decrypt;
        input [18:0] data_in;
        begin
            Decrypt = data_in ^ 19'h1FFFF;
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
        end else begin
            pc <= pc + 1;
        end
    end

    always @(instruction) begin
        opcode <= instruction[18:15];
        reg1 <= instruction[14:10];
        reg2 <= instruction[9:5];
        reg3 <= instruction[4:0];
    end
  
    always @(*) begin
        mem_write_en = 0;
        case (opcode)
            4'b0000: alu_result = register_file[reg1] + register_file[reg2]; 
            4'b0001: alu_result = register_file[reg1] - register_file[reg2]; 
            4'b0010: alu_result = register_file[reg1] ^ register_file[reg2]; 
            4'b0011: alu_result = register_file[reg1] & register_file[reg2]; 
            4'b0100: alu_result = register_file[reg1] | register_file[reg2]; 
            4'b0101: alu_result = register_file[reg1] << register_file[reg2]; 
            4'b0110: alu_result = register_file[reg1] >> register_file[reg2]; 
            4'b0111: alu_result = {register_file[reg1][17:0], register_file[reg1][18]}; 
            4'b1000: alu_result = {register_file[reg1][0], register_file[reg1][18:1]}; 
            4'b1001: begin 
                encrypted_data = Encrypt(mem_data_in);
                mem_address = register_file[reg1];
                mem_data = encrypted_data;
                mem_write_en = 1;
            end
            4'b1010: begin 
                decrypted_data = Decrypt(mem_data_in);
                mem_address = register_file[reg1];
                mem_data = decrypted_data;
                mem_write_en = 1;
            end
            4'b1100: alu_result = mem_data_in; 
            4'b1101: begin 
                mem_address = register_file[reg1];
                mem_data = register_file[reg2];
                mem_write_en = 1;
            end
            4'b1110: pc <= register_file[reg1]; 
            4'b1111: if (alu_result == 0) pc <= register_file[reg1]; 
            default: alu_result = 0; 
        endcase
    end

    assign pc_out = pc;
    assign mem_data_out = mem_data;
    assign mem_write = mem_write_en;

endmodule