module register_file (ra,rb,rw,clk,write,busa,busb,busw,reset);
 
 input [4:0]     ra,rb,rw;
 input           write,clk,reset; 
 input [31:0]    busw;
 output[31:0]    busa,busb;
 
 reg   [31:0]  r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17;
 reg   [31:0]  r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,r30,r31;
 wire  [31:0]  r0,dca,dcb,dcw;
 
 assign      r0 = 32'd0;
 
 assign      busa = dca[0] ? r0 : 32'dz;
 assign      busa = dca[1] ? r1 : 32'dz;
 assign      busa = dca[2] ? r2 : 32'dz;
 assign      busa = dca[3] ? r3 : 32'dz;
 assign      busa = dca[4] ? r4 : 32'dz;
 assign      busa = dca[5] ? r5 : 32'dz;
 assign      busa = dca[6] ? r6 : 32'dz;
 assign      busa = dca[7] ? r7 : 32'dz;
 assign      busa = dca[8] ? r8 : 32'dz;
 assign      busa = dca[9] ? r9 : 32'dz;
 assign      busa = dca[10] ? r10 : 32'dz;
 assign      busa = dca[11] ? r11 : 32'dz;
 assign      busa = dca[12] ? r12 : 32'dz;
 assign      busa = dca[13] ? r13 : 32'dz;
 assign      busa = dca[14] ? r14 : 32'dz;
 assign      busa = dca[15] ? r15 : 32'dz;
 assign      busa = dca[16] ? r16 : 32'dz;
 assign      busa = dca[17] ? r17 : 32'dz;
 assign      busa = dca[18] ? r18 : 32'dz;
 assign      busa = dca[19] ? r19 : 32'dz;
 assign      busa = dca[20] ? r20 : 32'dz;
 assign      busa = dca[21] ? r21 : 32'dz;
 assign      busa = dca[22] ? r22 : 32'dz;
 assign      busa = dca[23] ? r23 : 32'dz;
 assign      busa = dca[24] ? r24 : 32'dz;
 assign      busa = dca[25] ? r25 : 32'dz;
 assign      busa = dca[26] ? r26 : 32'dz;
 assign      busa = dca[27] ? r27 : 32'dz;
 assign      busa = dca[28] ? r28 : 32'dz;
 assign      busa = dca[29] ? r29 : 32'dz;
 assign      busa = dca[30] ? r30 : 32'dz;
 assign      busa = dca[31] ? r31 : 32'dz;

 assign      busb = dcb[0] ? r0 : 32'dz;
 assign      busb = dcb[1] ? r1 : 32'dz;
 assign      busb = dcb[2] ? r2 : 32'dz;
 assign      busb = dcb[3] ? r3 : 32'dz;
 assign      busb = dcb[4] ? r4 : 32'dz;
 assign      busb = dcb[5] ? r5 : 32'dz;
 assign      busb = dcb[6] ? r6 : 32'dz;
 assign      busb = dcb[7] ? r7 : 32'dz;
 assign      busb = dcb[8] ? r8 : 32'dz;
 assign      busb = dcb[9] ? r9 : 32'dz;
 assign      busb = dcb[10] ? r10 : 32'dz;
 assign      busb = dcb[11] ? r11 : 32'dz;
 assign      busb = dcb[12] ? r12 : 32'dz;
 assign      busb = dcb[13] ? r13 : 32'dz;
 assign      busb = dcb[14] ? r14 : 32'dz;
 assign      busb = dcb[15] ? r15 : 32'dz;
 assign      busb = dcb[16] ? r16 : 32'dz;
 assign      busb = dcb[17] ? r17 : 32'dz;
 assign      busb = dcb[18] ? r18 : 32'dz;
 assign      busb = dcb[19] ? r19 : 32'dz;
 assign      busb = dcb[20] ? r20 : 32'dz;
 assign      busb = dcb[21] ? r21 : 32'dz;
 assign      busb = dcb[22] ? r22 : 32'dz;
 assign      busb = dcb[23] ? r23 : 32'dz;
 assign      busb = dcb[24] ? r24 : 32'dz;
 assign      busb = dcb[25] ? r25 : 32'dz;
 assign      busb = dcb[26] ? r26 : 32'dz;
 assign      busb = dcb[27] ? r27 : 32'dz;
 assign      busb = dcb[28] ? r28 : 32'dz;
 assign      busb = dcb[29] ? r29 : 32'dz;
 assign      busb = dcb[30] ? r30 : 32'dz;
 assign      busb = dcb[31] ? r31 : 32'dz;
 
 always @(posedge clk)
 begin
  if(~reset)
   begin
   r1  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[1])
         r1 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r2  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[2])
         r2 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r3  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[3])
         r3 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r4  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[4])
         r4 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r5  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[5])
         r5 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r6  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[6])
         r6 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r7  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[7])
         r7 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r8  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[8])
         r8 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r9  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[9])
         r9 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r10  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[10])
         r10 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r11  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[11])
         r11 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r12  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[12])
         r12 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r13  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[13])
         r13 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r14  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[14])
         r14 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r15  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[15])
         r15 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r16  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[16])
         r16 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r17  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[17])
         r17 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r18  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[18])
         r18 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r19  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[19])
         r19 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r20  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[20])
         r20 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r21  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[21])
         r21 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r22  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[22])
         r22 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r23  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[23])
         r23 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r24  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[24])
         r24 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r25  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[25])
         r25 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r26  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[26])
         r26 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r27  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[27])
         r27 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r28  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[28])
         r28 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r29  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[29])
         r29 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r30  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[30])
         r30 <= busw;
     end
  end
  
  always @(posedge clk)
 begin
  if(~reset)
   begin
   r31  <= 32'd0;
   end
   else 
     begin
       if(write & dcw[31])
         r31 <= busw;
     end
  end
 //function decoder define 
  function [31:0] dc;
    input  [4:0]  rx;
     begin
     dc = 32'd0;
   case(rx)
     5'd0:dc[0] = 1'd1;
     5'd1:dc[1] = 1'd1;
     5'd2:dc[2] = 1'd1;
     5'd3:dc[3] = 1'd1;
     5'd4:dc[4] = 1'd1;
     5'd5:dc[5] = 1'd1;
     5'd6:dc[6] = 1'd1;
     5'd7:dc[7] = 1'd1;
     5'd8:dc[8] = 1'd1;
     5'd9:dc[9] = 1'd1;
     5'd10:dc[10] = 1'd1;
     5'd11:dc[11] = 1'd1;
     5'd12:dc[12] = 1'd1;
     5'd13:dc[13] = 1'd1;
     5'd14:dc[14] = 1'd1;
     5'd15:dc[15] = 1'd1;
     5'd16:dc[16] = 1'd1;
     5'd17:dc[17] = 1'd1;
     5'd18:dc[18] = 1'd1;
     5'd19:dc[19] = 1'd1;
     5'd20:dc[20] = 1'd1;
     5'd21:dc[21] = 1'd1;
     5'd22:dc[22] = 1'd1;
     5'd23:dc[23] = 1'd1;
     5'd24:dc[24] = 1'd1;
     5'd25:dc[25] = 1'd1;
     5'd26:dc[26] = 1'd1;
     5'd27:dc[27] = 1'd1;
     5'd28:dc[28] = 1'd1;
     5'd29:dc[29] = 1'd1;
     5'd30:dc[30] = 1'd1;
     5'd31:dc[31] = 1'd1;
     default: dc  = 32'd0;
   endcase  
     end
    endfunction 
    
    assign dca = dc(ra);
    assign dcb = dc(rb);
    assign dcw = dc(rw);
 
 /*always @(rw)
 begin
   dcw = 0;
   case(rw)
     5'd0:dcw[0] = 32'd1;
     5'd1:dcw[1] = 32'd1;
     5'd2:dcw[2] = 32'd1;
     5'd3:dcw[3] = 32'd1;
     5'd4:dcw[4] = 32'd1;
     5'd5:dcw[5] = 32'd1;
     5'd6:dcw[6] = 32'd1;
     5'd7:dcw[7] = 32'd1;
     5'd8:dcw[8] = 32'd1;
     5'd9:dcw[9] = 32'd1;
     5'd10:dcw[10] = 32'd1;
     5'd11:dcw[11] = 32'd1;
     5'd12:dcw[12] = 32'd1;
     5'd13:dcw[13] = 32'd1;
     5'd14:dcw[14] = 32'd1;
     5'd15:dcw[15] = 32'd1;
     5'd16:dcw[16] = 32'd1;
     5'd17:dcw[17] = 32'd1;
     5'd18:dcw[18] = 32'd1;
     5'd19:dcw[19] = 32'd1;
     5'd20:dcw[20] = 32'd1;
     5'd21:dcw[21] = 32'd1;
     5'd22:dcw[22] = 32'd1;
     5'd23:dcw[23] = 32'd1;
     5'd24:dcw[24] = 32'd1;
     5'd25:dcw[25] = 32'd1;
     5'd26:dcw[26] = 32'd1;
     5'd27:dcw[27] = 32'd1;
     5'd28:dcw[28] = 32'd1;
     5'd29:dcw[29] = 32'd1;
     5'd30:dcw[30] = 32'd1;
     5'd31:dcw[31] = 32'd1;
     default: dcw  = 32'd0;
   endcase
 end
 
 always @(ra)
 begin
   dca = 0;
   case(ra)
     5'd0:dca[0] = 32'd1;
     5'd1:dca[1] = 32'd1;
     5'd2:dca[2] = 32'd1;
     5'd3:dca[3] = 32'd1;
     5'd4:dca[4] = 32'd1;
     5'd5:dca[5] = 32'd1;
     5'd6:dca[6] = 32'd1;
     5'd7:dca[7] = 32'd1;
     5'd8:dca[8] = 32'd1;
     5'd9:dca[9] = 32'd1;
     5'd10:dca[10] = 32'd1;
     5'd11:dca[11] = 32'd1;
     5'd12:dca[12] = 32'd1;
     5'd13:dca[13] = 32'd1;
     5'd14:dca[14] = 32'd1;
     5'd15:dca[15] = 32'd1;
     5'd16:dca[16] = 32'd1;
     5'd17:dca[17] = 32'd1;
     5'd18:dca[18] = 32'd1;
     5'd19:dca[19] = 32'd1;
     5'd20:dca[20] = 32'd1;
     5'd21:dca[21] = 32'd1;
     5'd22:dca[22] = 32'd1;
     5'd23:dca[23] = 32'd1;
     5'd24:dca[24] = 32'd1;
     5'd25:dca[25] = 32'd1;
     5'd26:dca[26] = 32'd1;
     5'd27:dca[27] = 32'd1;
     5'd28:dca[28] = 32'd1;
     5'd29:dca[29] = 32'd1;
     5'd30:dca[30] = 32'd1;
     5'd31:dca[31] = 32'd1;
     default: dca  = 32'd0;
   endcase
 end
 
 always @(rb)
 begin
   dcb = 0;
   case(rb)
     5'd0:dcb[0] = 32'd1;
     5'd1:dcb[1] = 32'd1;
     5'd2:dcb[2] = 32'd1;
     5'd3:dcb[3] = 32'd1;
     5'd4:dcb[4] = 32'd1;
     5'd5:dcb[5] = 32'd1;
     5'd6:dcb[6] = 32'd1;
     5'd7:dcb[7] = 32'd1;
     5'd8:dcb[8] = 32'd1;
     5'd9:dcb[9] = 32'd1;
     5'd10:dcb[10] = 32'd1;
     5'd11:dcb[11] = 32'd1;
     5'd12:dcb[12] = 32'd1;
     5'd13:dcb[13] = 32'd1;
     5'd14:dcb[14] = 32'd1;
     5'd15:dcb[15] = 32'd1;
     5'd16:dcb[16] = 32'd1;
     5'd17:dcb[17] = 32'd1;
     5'd18:dcb[18] = 32'd1;
     5'd19:dcb[19] = 32'd1;
     5'd20:dcb[20] = 32'd1;
     5'd21:dcb[21] = 32'd1;
     5'd22:dcb[22] = 32'd1;
     5'd23:dcb[23] = 32'd1;
     5'd24:dcb[24] = 32'd1;
     5'd25:dcb[25] = 32'd1;
     5'd26:dcb[26] = 32'd1;
     5'd27:dcb[27] = 32'd1;
     5'd28:dcb[28] = 32'd1;
     5'd29:dcb[29] = 32'd1;
     5'd30:dcb[30] = 32'd1;
     5'd31:dcb[31] = 32'd1;
     default: dcb  = 32'd0;
   endcase
 end*/
 
endmodule
