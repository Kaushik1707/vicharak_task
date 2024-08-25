module cpu_testbench;
    reg clk;
    reg reset;
    reg [18:0] instruction;
    wire [18:0] pc_out;
    reg [18:0] mem_data_in;
    wire [18:0] mem_address;
    wire [18:0] mem_data_out;
    wire mem_write;

    CPU uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .pc_out(pc_out),
        .mem_data_in(mem_data_in),
        .mem_address(mem_address),
        .mem_data_out(mem_data_out),
        .mem_write(mem_write)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin
        reset = 1;
        #10 reset = 0;

        
        instruction = 19'b1001_00001_00010_00000; 
        mem_data_in = 19'b0000000000000001111; 
        #10;

        
        instruction = 19'b1010_00001_00010_00000; 
        mem_data_in = 19'b1111111111111110000; 
        #10;
      
        #100 $finish;
    end

        #100 $finish;
endmodule