module test_alu;
  
 reg        [31:0] t_operand_a,t_operand_b;
 reg        [1:0]  t_alu_selection,t_shift_op,t_log_op;
 reg               t_ariph_op;
 reg        [4:0]  t_shift_amount;
 wire       [31:0] t_alu_result;
 wire              t_overflow,t_zero;
 
 
 alu a1 ( .operand_a(t_operand_a),.operand_b(t_operand_b),.alu_selection(t_alu_selection),
          .ariph_op(t_ariph_op),
          .shift_op(t_shift_op),.log_op(t_log_op),.alu_result(t_alu_result),.overflow(t_overflow),
          .shift_amount(t_shift_amount),.zero(t_zero)); 
          
          
  task changing_operand;
    input [31:0] op_a;
    input [31:1] op_b;
    begin
    t_operand_a <= op_a;
    t_operand_b <= op_b;
    end
   endtask  
   
   task changing_alu_func;
   input [1:0] choose;
   begin
   t_alu_selection <= choose; 
   end
   endtask  
   
   task changing_shift_log_ariph;
   input [1:0] shift_choose;
   input [1:0] log_choose;
   input       ariph_choose;
   begin
   t_shift_op <= shift_choose;
   t_log_op   <= log_choose;
   t_ariph_op <= ariph_choose;
   end 
   endtask
   
   task changing_shift_amount;
   input [4:0] choose_shift;
   begin
   t_shift_amount <= choose_shift;
   end
   endtask
   
   initial #10000 $stop;
   
   initial
   begin
   changing_operand(32'd57389,32'd222290);
   changing_alu_func(2'b10);
   changing_shift_log_ariph(2'b00,2'b00,1'b0);
   changing_shift_amount(5'd7);
   #100
   changing_alu_func(2'b01);
   changing_operand(32'd7,32'd9);
   changing_shift_log_ariph(2'b01,2'b01,1'b1);
   end
  
endmodule

module alu (operand_a,operand_b,alu_selection,ariph_op,shift_op,log_op,alu_result,overflow,zero,shift_amount);
 
 input      [31:0]  operand_a,operand_b;
 input      [ 4:0]  shift_amount;
 input      [ 1:0]  alu_selection,shift_op,log_op;
 input              ariph_op;
 
 output reg [31:0]  alu_result;
 output             overflow,zero;
 
 reg    [32:0] ariph_result;
 reg    [31:0] overflow_detect,logic_result,shift_result;
 reg    [62:0] extend_data;
 reg    [46:0] mux_one;
 reg    [38:0] mux_two;
 reg    [34:0] mux_three;
 reg    [32:0] mux_four;
 reg    [31:0] mux_five;
 wire          less_then;
 wire          overflow;
 wire   [4:0]  shifting;
 wire   [32:0] two_s_complement;
 wire          one_bit_sumator;
 wire   [31:0] set_on_less_result;
 

 assign shifting           = shift_amount^{5{(~shift_op[0]&~shift_op[1])}};
 assign overflow           = ariph_result[32]^overflow_detect[31];
 assign less_then          = overflow^ariph_result[31];
 assign two_s_complement   = operand_b^{32{ariph_op}};
 assign zero               = ~(|alu_result);
 assign one_bit_sumator    = operand_a[31] ^ two_s_complement[31];
 assign set_on_less_result = {31'd0,less_then};
 
 always @(operand_a or operand_b or ariph_op or two_s_complement or one_bit_sumator or overflow_detect)
 begin
 overflow_detect = operand_a[30:0] + two_s_complement[30:0] + ariph_op; 
 ariph_result    = {{(operand_a[31] & two_s_complement[31] | overflow_detect[31] & one_bit_sumator),(one_bit_sumator^overflow_detect[31])},overflow_detect[30:0]};
 end
 
 always @(operand_a or operand_b or log_op)
 begin
 case(log_op)
     2'b00: logic_result =   operand_a & operand_b;
     2'b01: logic_result =   operand_a | operand_b;
     2'b10: logic_result = ~(operand_a | operand_b);
     2'b11: logic_result =   operand_a ^ operand_b;
     default:
            logic_result =   32'd0;
 endcase 
 end
 
 always @(alu_selection or logic_result or ariph_result or shift_result or less_then )
 begin
   case(alu_selection)
     2'b00: alu_result =   shift_result;
     2'b01: alu_result =   {31'd0,less_then};
     2'b10: alu_result =   ariph_result[31:0];
     2'b11: alu_result =   logic_result;
     default:
            alu_result =   32'd0;
   endcase  
    
 end
 
 always @(shift_amount or operand_b or shift_op or shifting)
 begin
   case(shift_op)
     2'b00: extend_data = {operand_b,31'd0};
     2'b01: extend_data = {31'd0,operand_b};
     2'b10: extend_data = {{31{operand_b[31]}},operand_b};
     2'b11: extend_data = {operand_b[30:0],operand_b[31:0]};
     default: 
            extend_data = 63'd0;
   endcase
  
   mux_one   = shifting[4] ? extend_data[62:16]: extend_data[46:0];
   mux_two   = shifting[3] ? mux_one    [46:8] : mux_one    [38:0];
   mux_three = shifting[2] ? mux_two    [38:4] : mux_two    [34:0];
   mux_four  = shifting[1] ? mux_three  [34:2] : mux_three  [32:0];
   mux_five  = shifting[0] ? mux_four   [32:1] : mux_four   [31:0];
   
   shift_result = mux_five;
   
 end
 
endmodule