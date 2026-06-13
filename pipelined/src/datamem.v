module data_mem (
    output reg [63:0] ReadData,    
    input  [63:0]   Address,       
    input  [63:0]   WriteData,     
    input           MemRead,       
    input           MemWrite,      
    input           clk            
);

    // 512 bytes of memory; each element is 8 bits
    reg [7:0] M [0:511];
    integer i;
    // Combinational read: If MemRead is asserted, output 8 consecutive bytes
    always @(*) begin
        if (MemRead)
            ReadData = { M[Address],
                         M[Address+1],
                         M[Address+2], 
                         M[Address+3],
                         M[Address+4],
                         M[Address+5],
                         M[Address+6],
                         M[Address+7]};
        
    end

    // Write operation on the negative edge of clk:
    // If MemWrite is asserted, store 64-bit WriteData into 8 consecutive bytes.
    always @(negedge clk) begin
        if (MemWrite) begin
            M[Address]     <= WriteData[63:56];
            M[Address + 1] <= WriteData[55:48];
            M[Address + 2] <= WriteData[47:40];
            M[Address + 3] <= WriteData[39:32];
            M[Address + 4] <= WriteData[31:24];
            M[Address + 5] <= WriteData[23:16];
            M[Address + 6] <= WriteData[15:8];
            M[Address + 7] <= WriteData[7:0];
        end
        for (i=0;i<=40;i=i+1) begin
            $display ("M[%0d] = %0d", i, M[i]);
        end
    end

    // Optionally initialize memory contents from a file.
    // The file "data_memory_preload.txt" should contain the initial memory content in binary format.
    initial begin
        $readmemb("data_data.txt", M);
    end

endmodule
