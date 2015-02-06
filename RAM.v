module test_data_memory;

parameter PERIOD = 50;

reg clk,n_reset;

always @ (clk)
#(PERIOD/2) clk <= ~clk;

initial
begin
 clk     <= 0;
 n_reset <= 0;
 #PERIOD 
 n_reset <= 1;
 #(10000*PERIOD)
 $stop;
end

data_memory dm_dut (.address(),
                    .data_in(),
                    .data_out(),
                    .clk(clk),
                    .mem_read(),
                    .mem_write(),
                    .n_reset(n_reset));

endmodule


module data_memory(address,data_in,data_out,clk,mem_read,mem_write,n_reset,oc,pin_data);
  
    localparam TCCR_ADDR         = 32'd0;
    localparam TCNT_ADDR         = 32'd1;
    localparam OCR_ADDR          = 32'd2;
    localparam PIN_ADDR          = 32'd3;
    
    localparam CS0               = 0;
    localparam CS1               = 1;
    localparam CS2               = 2;
    localparam WGM1              = 3;
    localparam COM0              = 4;
    localparam COM1              = 5;
    localparam WGM0              = 6;
    localparam FOC               = 7;
    
    localparam ADDR_WIDTH        = 32;
    localparam BYTE_WIDTH        = 8;
    localparam VALUE_AFTER_RESET = 32'd0;
    
    localparam NORMAL            = 2'd0;
    localparam PWM_PHASE_CORRECT = 2'd1;
    localparam CTC               = 2'd2;
    localparam PWM_FAST          = 2'd3;
    localparam MAX               = 32'd255;
    localparam MIN               = 32'd00;
  
    input      [31:0] address,data_in,pin_data;
    input             clk,mem_read,mem_write,n_reset;
    output     [31:0] data_out;
    output reg        oc;
   
    reg        [4*BYTE_WIDTH-1:0] ram [4:100];
    reg        [31:0] tccr,tcnt,ocr,ocr_buffer,pin,latch_data;
    reg        [ 9:0] prescaler;
    reg        [ 3:0] waveform_generation_mode,compare_output_mode;
    reg               timer_clock,decrement;
    wire              tccr_addr,tcnt_addr,ocr_addr,pin_addr;
    wire              divide_8,divide_32,divide_64,divide_128,divide_256,divide_1024;
    wire              match,max,min;
  
    assign     tccr_addr = (address == TCCR_ADDR);
    assign     tcnt_addr = (address == TCNT_ADDR);
    assign     ocr_addr  = (address == OCR_ADDR );
    assign     pin_addr  = (address == PIN_ADDR);
    
    assign     divide_8    = prescaler[2] & prescaler[1] & prescaler[0];
    assign     divide_32   = prescaler[4] & prescaler[3] & divide_8;
    assign     divide_64   = prescaler[5] & divide_32;
    assign     divide_128  = prescaler[6] & divide_64;
    assign     divide_256  = prescaler[7] & divide_128;
    assign     divide_1024 = & prescaler;
    
    assign     match       = ~|(ocr ^ tcnt);
    assign     max         = ~|(MAX ^ tcnt);
    assign     min         = ~|(MIN ^ tcnt);
    
	  assign     data_out    = (mem_read & ~(pin_addr | tccr_addr | tcnt_addr | ocr_addr)) ? ram[address]    : 32'dz; 
	  assign     data_out    = (mem_read & tccr_addr) ? tccr            : 32'dz;
	  assign     data_out    = (mem_read & tcnt_addr) ? tcnt            : 32'dz;
	  assign     data_out    = (mem_read & ocr_addr)  ? ocr             : 32'dz;
	  assign     data_out    = (mem_read & pin_addr)  ? pin             : 32'dz;

    //synchronization 
    always @(pin_data or clk)
    begin
      if(clk)
        latch_data = pin_data;
    end
    
    always @(posedge clk)
	  begin
	    if(~n_reset)
	       tccr <= VALUE_AFTER_RESET;
	     else if(mem_write & tccr_addr)
	       tccr <= data_in;
	  end
	  
	  always @(posedge clk)
	  begin
	    if(~n_reset)
	       pin <= VALUE_AFTER_RESET;
	     else 
	       pin <= latch_data;
	  end
	  
	  always @(posedge clk)
	  begin
	    if(~n_reset)
	       ocr <= VALUE_AFTER_RESET;
	     else if(mem_write & ocr_addr & ~(waveform_generation_mode[1] | waveform_generation_mode[3]))
	       ocr <= data_in;
	     else if (waveform_generation_mode[1] | waveform_generation_mode[3])
	       begin
	       if(min)
	       ocr <= ocr_buffer;
	       end
	  end
	  
	  always @ (posedge clk)
	  begin
	    if(~n_reset)
	       ocr_buffer <= VALUE_AFTER_RESET;
	     else if(mem_write & ocr_addr & (waveform_generation_mode[1] | waveform_generation_mode[3]))
	       ocr_buffer <= data_in;
	     else if (~(waveform_generation_mode[1] | waveform_generation_mode[3]))
	      ocr_buffer <= ocr;
	  end
	  
	  always @(posedge clk  or posedge min or posedge max)
	  begin
	    if(~n_reset)
	      decrement <= 1'b0;
	   // else if (timer_clock)
	    if(min)
	      decrement <= 1'b0;
	    if(max)
	      decrement <= 1'b1;
	  end
	  
	  always @(posedge clk)
	  begin
	    if(~n_reset)
	       tcnt <= VALUE_AFTER_RESET;
	     else if(mem_write & tcnt_addr)
	       tcnt <= data_in;
	     else if (timer_clock)
	       begin
	       tcnt <= tcnt + 32'd1;
	       if (waveform_generation_mode[2])
	       begin
	         if(match)
	         tcnt <= MIN; 
	       end 
	       else if (waveform_generation_mode[1])
	       begin
	         if(decrement)
	          tcnt <= tcnt - 32'd1;
	       end
	       else if (tcnt == MAX)
	         tcnt <= MIN;
	       end
	  end
	  
	  always @(posedge clk)
	   begin
	     if(~n_reset)
	       oc <= 1'b0;
	     else if (timer_clock)
	     begin
	       if(waveform_generation_mode[2] & match)
	          begin
	           if(compare_output_mode[1])
	             oc <= ~oc;
	           else if (compare_output_mode[2])
	             oc <= 1'b0;
	           else if (compare_output_mode[3])
	             oc <= 1'b1;
	          end
	        if(waveform_generation_mode[3])
	          begin
	            if(compare_output_mode[2])
	              begin
	                if(match)
	                  oc <= 1'b0;
	                else if(max)
	                  oc <= 1'b1;
	              end
	             else if(compare_output_mode[3])
	               begin
	                if(match)
	                  oc <= 1'b1;
	                else if(max)
	                  oc <= 1'b0;
	               end
	          end
	          if(waveform_generation_mode[1])
	          begin
	            if(compare_output_mode[2])
	              begin
	                if(match & ~decrement)
	                  oc <= 1'b0;
	                else if(match & decrement)
	                  oc <= 1'b1;
	              end
	             else if(compare_output_mode[3])
	               begin
	                if(match & decrement)
	                  oc <= 1'b0;
	                else if(match & ~decrement)
	                  oc <= 1'b1;
	               end
	          end
	      end
	   end

    always @(posedge clk)
	   begin
	    if(mem_write)
	     ram[address] <= data_in;
	   end
	  
	  always @(divide_8 or divide_32 or divide_64 or divide_128 or divide_256 or divide_1024 or tccr[CS0] or tccr[CS1] or tccr[CS2] or  clk)
	  begin
	    case({tccr[CS2],tccr[CS1],tccr[CS0]})
	      3'b000: timer_clock = 1'b0;
	      3'b001: timer_clock = ~clk;
	      3'b010: timer_clock = divide_8;
	      3'b011: timer_clock = divide_32;
	      3'b100: timer_clock = divide_64;
	      3'b101: timer_clock = divide_128;
	      3'b110: timer_clock = divide_256;
	      3'b111: timer_clock = divide_1024;
	      default: timer_clock = 1'b0;
	     endcase
	  end
	  
	  always @(tccr[WGM1] or tccr[WGM0] or tccr[COM0] or tccr[COM1])
	  begin 
	    case({tccr[WGM1],tccr[WGM0]})
	      NORMAL:            waveform_generation_mode = 4'd1; 
	      PWM_PHASE_CORRECT: waveform_generation_mode = 4'd2; 
	      CTC:               waveform_generation_mode = 4'd4;
	      PWM_FAST:          waveform_generation_mode = 4'd8;
	      default:           waveform_generation_mode = 4'd0; 
	    endcase
	    case ({tccr[COM1],tccr[COM0]})
	      2'b00:             compare_output_mode      = 4'd1;
	      2'b01:             compare_output_mode      = 4'd2;
	      2'b10:             compare_output_mode      = 4'd4;
	      2'b11:             compare_output_mode      = 4'd8;
	      default:           compare_output_mode      = 4'd0;
	    endcase
	  end
	  
	  always @(posedge clk)
	  begin
	    if(~n_reset)
	      prescaler <= 10'd0;
	    else prescaler <= prescaler + 10'd1;
	  end
	  
	       
	 
endmodule
