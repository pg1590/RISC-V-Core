module reg_file_64bit (
    input  wire         clk,
    input  wire [4:0]   rs1_addr,  
    input  wire [4:0]   rs2_addr,  
    output wire [63:0]  rs1_data,  
    output wire [63:0]  rs2_data,  
    input  wire [4:0]   rd_addr,   
    input  wire [63:0]  rd_data,   
    input  wire reg_write  
);

    reg [63:0] registers [0:31];
    integer k;
    initial begin
        for (k=0 ;k<32 ;k=k+1 ) begin
            registers[k] = 64'b0;
        end
    end

    assign rs1_data = registers[rs1_addr];
    assign rs2_data = registers[rs2_addr];

    integer i;
    always @(negedge clk) begin
        if (reg_write) begin
            if (rd_addr != 5'd0) begin
                registers[rd_addr] <= rd_data;
            end
        end
    end

    always @(*) begin
        $display ("Time: %0t", $time);
        for (i = 0; i <= 31; i = i + 1) begin
            $display ("registers[%0d] = %0d", i, registers[i]);
        end
    end

endmodule
