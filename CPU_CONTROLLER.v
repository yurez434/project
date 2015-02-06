// supported commands:
//                     add
//                     sub
//                     and
//                     or
//                     xor
//                     slt
//                     addi
//                     slti
//                     andi
//                     ori
//                     xori
//                     lw
//                     sw
//                     beq
//                     bne
//                     j
//                     sll
//                     srl
//                     sra

module controller (fetch_instruction,reg_dst,reg_write,ext_op,alu_src,mem_read,mem_write,mem_to_reg,beq,bne,j,alu_selection,log_op,shift_op,ariph_op,we_bypass,we_stall,re1,re2,alu,alui_lw_sw,lw_);
 
 input      [31:0]fetch_instruction;
 output           ariph_op,reg_dst,reg_write,ext_op,alu_src,mem_read,mem_write,mem_to_reg,beq,bne,j,we_bypass,we_stall,re1,re2,alu,alui_lw_sw,lw_;
 output reg [1:0] alu_selection,log_op,shift_op;
 
 wire       [5:0] op,func;
 wire             r_type,addi,slti,andi,ori,xori,lw,sw,add,sub,and_,or_,xor_,slt,sll,srl,sra;
 
 assign      op     = fetch_instruction[31:26];
 assign      func   = fetch_instruction[5:0];
 assign      lw_    = lw;
 
 //__________operation_decoder____________________________________________________
 assign      r_type = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];  //0x00
 assign      addi   = ~op[5] & ~op[4] &  op[3] & ~op[2] & ~op[1] & ~op[0];  //0x08
 assign      slti   = ~op[5] & ~op[4] &  op[3] & ~op[2] &  op[1] & ~op[0];  //0x0a
 assign      andi   = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] & ~op[0];  //0x0c
 assign      ori    = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] &  op[0];  //0x0d
 assign      xori   = ~op[5] & ~op[4] &  op[3] &  op[2] &  op[1] & ~op[0];  //0x0e
 assign      lw     =  op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] &  op[0];  //0x23 
 assign      sw     =  op[5] & ~op[4] &  op[3] & ~op[2] &  op[1] &  op[0];  //0x2b 
 assign      j      = ~op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] & ~op[0];  //0x02
 assign      beq    = ~op[5] & ~op[4] & ~op[3] &  op[2] & ~op[1] & ~op[0];  //0x04
 assign      bne    = ~op[5] & ~op[4] & ~op[3] &  op[2] & ~op[1] &  op[0];  //0x05
  //__________function_decoder____________________________________________________
 assign      sll    = ~func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];  //0x00
 assign      srl    = ~func[5] & ~func[4] & ~func[3] & ~func[2] &  func[1] & ~func[0];  //0x02
 assign      sra    = ~func[5] & ~func[4] & ~func[3] & ~func[2] &  func[1] &  func[0];  //0x03
 assign      add    =  func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];  //0x20
 assign      sub    =  func[5] & ~func[4] & ~func[3] & ~func[2] &  func[1] & ~func[0];  //0x22
 assign      and_   =  func[5] & ~func[4] & ~func[3] &  func[2] & ~func[1] & ~func[0];  //0x24
 assign      or_    =  func[5] & ~func[4] & ~func[3] &  func[2] & ~func[1] &  func[0];  //0x25
 assign      xor_   =  func[5] & ~func[4] & ~func[3] &  func[2] &  func[1] & ~func[0];  //0x26
 assign      slt    =  func[5] & ~func[4] &  func[3] & ~func[2] &  func[1] & ~func[0];  //0x2a                                                  
 //__________main_control_signals_________________________________________________
 assign      reg_dst    = r_type;
 assign      mem_read   = lw;
 assign      mem_to_reg = lw;
 assign      reg_write  = ~(sw     | beq | bne | j);
 assign      ext_op     = ~(andi   | ori | xori);
 assign      alu_src    = ~(r_type | beq | bne);
 assign      mem_write  = sw;
 //__________alu_control_signals__________________________________________________
 assign      ariph_op   = ~(add | addi | lw | sw);
 //__________stall_implementation_________________________________________________
 assign      we_bypass  = (r_type | addi | slti | andi | ori | xori  | lw | beq | bne);
 assign      we_stall   =  lw;
 assign      re1        = (r_type | addi | slti | andi | ori | xori | lw | sw | beq | bne);
 assign      re2        = (r_type | lw   | sw   | slt | beq | bne);
 assign      alu        =  r_type;
 assign      alui_lw_sw =  addi   | slti | andi | ori | xori | lw | sw ;
 

  always @(slt or slti or add or addi or ori or lw or sw or sub or beq or bne or and_ or or_ or xor_ or andi or xori or sll or srl or sra or r_type)
 begin 
   alu_selection = 2'b00;
  if      ((sll | srl | sra) & r_type)
   alu_selection = 2'b00;
  else if ((slt & r_type) | slti)
   alu_selection = 2'b01;
  else if (((add | sub ) & r_type) | addi | lw | sw  | beq | bne)
   alu_selection = 2'b10;
  else if (((and_ | or_ | xor_) & r_type) | andi | ori | xori)
   alu_selection = 2'b11;
 end
 
 
  always @(and_ or andi or or_ or ori or xor_ or xori or r_type)
 begin
  log_op = 2'b00;
  if      (and_ & r_type  | andi)
   log_op = 2'b00;
  else if (or_ & r_type   | ori)
   log_op = 2'b01;
  else if (xor_  & r_type | xori)
   log_op = 2'b11;
 end
 
  always @(sll or srl or sra or r_type)
 begin
   shift_op = 2'b00;
   if      (sll & r_type)
    shift_op = 2'b00;
   else if (srl & r_type)
    shift_op = 2'b01;
   else if (sra & r_type)
    shift_op = 2'b10;
 end
  
endmodule
