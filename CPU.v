module cpu_test;
  
  parameter  PERIOD = 100;
  reg [31:0] pin_data;
  reg        reset,clk;
  wire       oc;
  
  cpu  dut (.n_reset(reset),
            .clk(clk),
            .oc(oc),
            .pin_data(pin_data));
  
  initial
	begin
		//$readmemh("rom_init.txt",dut.cpu_instr_mem.rom);
		$readmemh("rom_init.txt",dut.rom);
		$readmemh("ram_init.txt",dut.cpu_data_memory.ram);
	end
	initial forever #(PERIOD/2) clk <= ~clk;
	initial #10000000 $stop;
	
	initial
	begin
	pin_data <= 32'd50;
	clk   <=0;
	reset <= 1'b0;
	#PERIOD
	reset <= 1'b1;
	#1000000
	pin_data <= 32'd250;
	end
  
endmodule

module cpu (clk,n_reset,oc,pin_data);
  
  input         clk,n_reset;
  input  [31:0] pin_data;
  output        oc;
  
  localparam   BYTE_WIDTH = 8;
  reg         [4*BYTE_WIDTH-1:0] rom [0:99];
  
  reg  [31:0] pc;
  wire [31:0] instruction,busa,busb,/*busw,*/extender,operand_b,data_out,alu_result,bypass_busa,bypass_busb,memory_bus_write;
  wire [29:0] add_one_to_pc,next_pc;
  wire        reg_dst,ext_op,alu_src,mem_to_reg,pc_src,zero,j,beq,bne,reg_write,mem_read,mem_write;
  wire [1:0]  log_op,shift_op,alu_selection;
  wire [2:0]  asrc,bsrc;                                                  //bypass signal
  wire        ariph_op,we_bypass,we_stall,re1,re2,stall,alu,alui_lw_sw,ir_source_decode,extra_comparator,lw; 
  wire [4:0]  rw;
  
  //----------------fetch_registers--------------
  reg [31:0]  fetch_instruction;
  reg [29:0]  fetch_add_one_to_pc;
  //---------------------------------------------
  //----------------decode_registers-------------
  reg         decode_mem_to_reg,decode_reg_write,decode_mem_read,decode_mem_write,decode_lw;
  reg  [1:0]  decode_log_op,decode_alu_selection,decode_shift_op;
  reg         decode_ariph_op,decode_we_stall,decode_we_bypass,decode_alu,decode_alui_lw_sw; 
  reg [4:0]   decode_rw,decode_shift_amount;
  reg [31:0]  decode_busa,decode_busb,decode_operand_b;
  //reg [29:0]  decode_add_one_to_pc;
  //reg [25:0]  decode_instruction;                 // 26 bit immediate for jump
  reg [4:0]   decode_r_s,decode_r_t,decode_r_d,decode_ws;   
  
  //---------------------------------------------
  //----------------execute_registers------------
  reg         execute_we_bypass;
  reg [31:0]  execute_busb,execute_alu_result;
  reg         execute_mem_to_reg,execute_reg_write,execute_mem_read,execute_mem_write,execute_alu,execute_alui_lw_sw/*,execute_nop*/;
  reg [4:0]   execute_rw,execute_r_t,execute_r_d,execute_ws;
  //---------------------------------------------
  //----------------memory_registers------------
  reg         memory_reg_write,memory_we_bypass;
  reg [4:0]   memory_rw,memory_r_t,memory_r_d,memory_ws;
  reg [31:0]  memory_bus_w;
  //---------------------------------------------
  
  /*instruction_memory cpu_instr_mem   (.address(pc[31:2]),
                                      .instruction(instruction));*/
                                      
  register_file      cpu_reg_file    (.ra(fetch_instruction[25:21]),
                                      .rb(fetch_instruction[20:16]),
                                      .rw(memory_rw),
                                      .clk(clk),
                                      .write(memory_reg_write),
                                      .busa(busa),
                                      .busb(busb),
                                      .busw(memory_bus_w),
                                      .reset(n_reset));
                                      
  alu                cpu_alu         (.operand_a(decode_busa),
                                      .operand_b(decode_operand_b),
                                      .alu_selection(decode_alu_selection),
                                      .ariph_op(decode_ariph_op),
                                      .shift_op(decode_shift_op),
                                      .log_op(decode_log_op),
                                      .alu_result(alu_result),
                                      .overflow(),
                                      .zero(zero),
                                      .shift_amount(decode_shift_amount));
                                      
  data_memory        cpu_data_memory (.address(execute_alu_result),
                                      .data_in(execute_busb),
                                      .data_out(data_out),
                                      .clk(clk),
                                      .mem_read(execute_mem_read),
                                      .mem_write(execute_mem_write),
                                      .n_reset(n_reset),
                                      .oc(oc),
                                      .pin_data(pin_data));
                                      
  controller         cpu_controller  (.fetch_instruction(fetch_instruction),
                                      .reg_dst(reg_dst),
                                      .reg_write(reg_write),
                                      .ext_op(ext_op),
                                      .alu_src(alu_src),
                                      .mem_read(mem_read),
                                      .mem_write(mem_write),
                                      .mem_to_reg(mem_to_reg),
                                      .beq(beq),
                                      .bne(bne),
                                      .j(j),
                                      .alu_selection(alu_selection),
                                      .log_op(log_op),
                                      .shift_op(shift_op),
                                      .ariph_op(ariph_op),
                                      .we_bypass(we_bypass),
                                      .we_stall(we_stall),
                                      .re1(re1),
                                      .re2(re2),
                                      .alu(alu),
                                      .alui_lw_sw(alui_lw_sw),
                                      .lw_(lw));
  
  //assign  busw              = mem_to_reg ? data_out  : alu_result;
  //assign  stall               = (~(fetch_instruction[25:21]^decode_ws) & decode_we | ~(fetch_instruction[25:21]^execute_ws) & execute_we | ~(fetch_instruction[25:21]^memory_ws) & memory_we) & re1 | (~(fetch_instruction[20:16]^decode_ws) & decode_we | ~(fetch_instruction[20:16]^execute_ws) & execute_we | ~(fetch_instruction[20:16]^memory_ws) & memory_we) & re2; 
  
  assign  rw                  = reg_dst    ? fetch_instruction[15:11] : fetch_instruction[20:16];
  assign  extender            = {{16{ext_op}} & {16{fetch_instruction[15]}},fetch_instruction[15:0]};
  assign  operand_b           = alu_src    ? extender  : bypass_busb; 
  assign  add_one_to_pc       = pc[31:2] + 30'd1;
  assign  next_pc             = j ? {fetch_add_one_to_pc[29:26],fetch_instruction[25:0]} : (fetch_add_one_to_pc + {{14{fetch_instruction[15]}},fetch_instruction[15:0]});
  assign  pc_src              = bne & ~extra_comparator | beq & extra_comparator | j; 
  assign  stall               = (~|(fetch_instruction[25:21]^decode_ws) & decode_we_stall  & re1 | ~|(fetch_instruction[20:16]^decode_ws) & decode_we_stall & re2) & ~(beq & extra_comparator | bne & ~extra_comparator);
  assign  ir_source_decode    = pc_src ;
  assign  extra_comparator    = ~|(bypass_busa ^ bypass_busb);
  
  assign  asrc[0]             = ~|(fetch_instruction[25:21]^decode_ws)  & decode_we_bypass  & re1 & |decode_ws;
  assign  asrc[1]             = ~|(fetch_instruction[25:21]^execute_ws) & execute_we_bypass & re1 & |execute_ws;
  assign  asrc[2]             = ~|(fetch_instruction[25:21]^memory_ws)  & memory_we_bypass  & re1 & |memory_ws;
  
  assign  bsrc[0]             = ~|(fetch_instruction[20:16]^decode_ws)  & decode_we_bypass  & re2 & |decode_ws & ~decode_lw;
  assign  bsrc[1]             = ~|(fetch_instruction[20:16]^execute_ws) & execute_we_bypass & re2 & |execute_ws;
  assign  bsrc[2]             = ~|(fetch_instruction[20:16]^memory_ws)  & memory_we_bypass  & re2 & |memory_ws;
  
  assign  bypass_busa         = asrc[0] ? alu_result : (asrc[1] ? memory_bus_write : ( asrc[2] ? memory_bus_w : busa));
  assign  bypass_busb         = bsrc[0] ? alu_result : (bsrc[1] ? memory_bus_write : ( bsrc[2] ? memory_bus_w : busb));
  
  assign  memory_bus_write    = execute_mem_to_reg ? data_out  : execute_alu_result;
  
  //---------------------------------------------------------------
  //---------------------FETCH/DECODE------------------------------
  //---------------------------------------------------------------  
                                  
  always @ (posedge clk)
  begin
    if(~n_reset)
      pc <= 32'd0;
    else
        begin
          
          if(stall) 
          pc        <= pc;
          else if(pc_src)
          pc [31:2] <= next_pc;
          else
          pc [31:2] <= add_one_to_pc;
        end
  end
 
  always @ (posedge clk)
  begin
    if(~n_reset)
      fetch_instruction <= 32'd0;
    else
      /*begin
      fetch_instruction <= instruction; 
      if (stall)
      fetch_instruction <= fetch_instruction;
      if (ir_source_decode)
      fetch_instruction <= 32'd0;
      end*/
      begin 
      if (stall)
      fetch_instruction <= fetch_instruction;
      else if (ir_source_decode)
      fetch_instruction <= 32'd0;
      else
      fetch_instruction <= rom[pc[31:2]];
      end
  end
  
  always @ (posedge clk)
  begin
    if(~n_reset)
       fetch_add_one_to_pc <= 30'd0;
    else
      begin
       fetch_add_one_to_pc <= add_one_to_pc; 
      end
  end
  //---------------------------------------------------------------
  //---------------------DECODE/EXECUTE----------------------------
  //---------------------------------------------------------------                                  
  always @ (posedge clk)
  begin
  if(~n_reset)
  begin
  decode_shift_amount  <= 4'b0;
  decode_mem_to_reg    <= 1'b0;
  decode_shift_op      <= 2'b0;
  decode_reg_write     <= 1'b0;
  decode_mem_read      <= 1'b0;
  decode_mem_write     <= 1'b0; 
  decode_ariph_op      <= 1'b0;
  decode_log_op        <= 2'b0;
  decode_alu_selection <= 2'b0;
  decode_rw            <= 5'b0;
  decode_busa          <= 32'b0;
  decode_busb          <= 32'b0; 
  decode_operand_b     <= 32'b0;
  decode_r_s           <= 5'b0;
  decode_r_t           <= 5'b0;
  decode_r_d           <= 5'b0;
  decode_we_stall      <= 1'b0;
  decode_we_bypass     <= 1'b0;
  decode_ws            <= 5'b0;
  decode_alu           <= 1'b0;
  decode_alui_lw_sw    <= 1'b0;
  decode_lw            <= 1'b0;
  end
  else
    begin
     decode_shift_amount  <= fetch_instruction[10:6];
     decode_mem_to_reg    <= stall ? 1'b0 : mem_to_reg;
     decode_reg_write     <= stall ? 1'b0 : reg_write;
     decode_mem_read      <= stall ? 1'b0 : mem_read;
     decode_mem_write     <= stall ? 1'b0 : mem_write; 
     decode_ariph_op      <= ariph_op;
     decode_log_op        <= log_op;
     decode_shift_op      <= shift_op;
     decode_alu_selection <= alu_selection; 
     decode_rw            <= rw;
     decode_busa          <= bypass_busa;
     decode_busb          <= bypass_busb; 
     decode_operand_b     <= operand_b;
     decode_r_s           <= fetch_instruction[25:21];
     decode_r_t           <= fetch_instruction[20:16];
     decode_r_d           <= fetch_instruction[15:11]; 
     decode_we_stall      <= stall ? 1'b0 : we_stall;
     decode_we_bypass     <= stall ? 1'b0 : we_bypass;
     decode_ws            <= alu ? fetch_instruction[15:11] : (alui_lw_sw ? fetch_instruction[20:16]: 5'b0);
     decode_alu           <= alu;
     decode_alui_lw_sw    <= alui_lw_sw;
     decode_lw            <= lw;
   end
  end
  //---------------------------------------------------------------
  //---------------------EXECUTE/MEMORY----------------------------
  //---------------------------------------------------------------
   always @ (posedge clk)
  begin
  if(~n_reset)
  begin
  execute_busb            <= 32'b0;
  execute_alu_result      <= 32'b0;
  execute_mem_to_reg      <= 1'b0;
  execute_reg_write       <= 1'b0;
  execute_mem_read        <= 1'b0;
  execute_mem_write       <= 1'b0;
  execute_rw              <= 5'b0;
  execute_we_bypass       <= 1'b0;
  execute_r_t             <= 5'b0;
  execute_r_d             <= 5'b0;
  execute_alu             <= 1'b0;
  execute_alui_lw_sw      <= 1'b0;
  execute_ws              <= 5'b0;
  end
   else
    begin
    execute_busb            <= decode_busb;
    execute_alu_result      <= alu_result;
    execute_mem_to_reg      <= decode_mem_to_reg;
    execute_reg_write       <= decode_reg_write;
    execute_mem_read        <= decode_mem_read;
    execute_mem_write       <= decode_mem_write;
    execute_rw              <= decode_rw;  
    execute_we_bypass       <= decode_we_bypass;
    execute_r_t             <= decode_r_t;
    execute_r_d             <= decode_r_d;
    execute_alu             <= decode_alu;
    execute_alui_lw_sw      <= decode_alui_lw_sw;
    execute_ws              <= decode_alu ? decode_r_d : (decode_alui_lw_sw ? decode_r_t : 5'b0);
    end
  end
  //--------------------------------------------------------------
  //---------------------MEMORY/WRITE_BACK------------------------
  //--------------------------------------------------------------
  always @ (posedge clk)
  begin
  if(~n_reset)
  begin
  memory_rw                  <= 4 'b0;
  memory_reg_write           <= 1 'b0;
  memory_bus_w               <= 32'b0;
  memory_we_bypass           <= 1'b0;
  memory_r_t                 <= 5'b0;
  memory_r_d                 <= 5'b0;
  memory_ws                  <= 5'b0;
  end 
   else
    begin
     memory_rw                <= execute_rw;
     memory_reg_write         <= execute_reg_write;
     memory_bus_w             <= memory_bus_write;
     memory_we_bypass         <= execute_we_bypass;
     memory_r_t               <= execute_r_t;
     memory_r_d               <= execute_r_d;
     memory_ws                <= execute_alu ? execute_r_d : (execute_alui_lw_sw ? execute_r_t: 5'b0);
    end
  end    
endmodule
















