`include "main.v"
module main_processor_tb();
    reg clk;
    
    // Instantiate the processor
    main uut (.clk(clk));
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("gtk.vcd");
        $dumpvars(0, main_processor_tb);
        #200
        
        $finish;
    end

endmodule
