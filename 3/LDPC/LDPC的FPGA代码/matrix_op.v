module matrix_op( clk,reset,bit_in,bit_in_en, media_in,media_in_en,
				  coder_first,
                  bit_out,bit_out_en, first_out,
                  data_out);

input	clk,reset;
input	bit_in,bit_in_en;
input[126:0]	media_in;
input	media_in_en;
input	coder_first;       //Ã¿Ò»×é±àÂëµÚÒ»¸öÊı¾İÊäÈëÖ¸Ê¾£¬±ãÓÚ´¦ÀíÏà³ËºóÖ±½Ó´æ´¢µ½out£¬²»±ØÒì»ò
//input	coder_last;

output[126:0]	data_out;
//output	data_out_en;
output	bit_out;
output	bit_out_en;
output	first_out;

reg first_out;
reg[126:0]	media;
reg	bit_out;
reg	bit_out_en;
reg[126:0]	data_out;
//reg	data_out_en;

always @(posedge clk)
begin
	if (!reset)
		begin
		media <= 127'd0;
		data_out <=	127'd0;
		//data_out_en	<= 1'b0;
		bit_out <= 1'b0;
		bit_out_en <= 1'b0;
		end			
	else
		begin
		if (bit_in_en)
			begin
			if(coder_first)
				begin
				if(bit_in)
					begin
					data_out <= media;
					end
				else
					begin
					data_out <= 127'd0;				
					end
				end
			else
				begin
				if(bit_in)
					begin
					data_out <= data_out^media;
					end
				end
				
		/*	if(coder_last)
				begin
				data_out_en	<= 1'b1;
				end
			else
				begin
				data_out_en	<= 1'b0;
				end	
				*/
				
			media <= {media[0],media[126:1]};
			first_out <= coder_first;
			bit_out <= bit_in;
			bit_out_en <= 1'b1;				
			end
		else
			begin
			bit_out_en<=1'b0;
			//data_out_en	<= 1'b0;
			end	

		if(media_in_en)  //Íâ²¿±£Ö¤µÚ127¸ö·ûºÅÊäÈëÊ±Í¬²½ÊäÈëmedia³õÊ¼ĞÅÏ¢
			begin
			media <= media_in;
			end
		end	
end
endmodule





module LDPC	(clk,reset,
			 data_in, data_in_en,	
			 velocity, /*ÊäÈëĞÅºÅÂëÂÊÑ¡Ôñ*/
		
			 data_out, data_out_en,
			 indication /*Êä³öĞÅºÅ£¬µÚÒ»¸ö127ÒªÉ¾³ıÇ°5³É7488£¬Ö¸Ê¾µÚÒ»¸ö127*/
				);

input	clk,reset;
input	data_in,data_in_en;
input[1:0]	velocity; //ÂëÂÊÑ¡ÔñĞÅºÅ
output[126:0]	data_out;//Êä³öĞÅºÅ
output	data_out_en;
output	indication;


parameter row_4 = 6'd24-1'b1;		// parameter column_4 = 6'd35-1'b1;  //0.4ÂëÂÊ
parameter row_6 = 6'd36-1'b1;		// parameter column_6 = 6'd23-1'b1;  //0.6ÂëÂÊ
parameter row_8 = 6'd48-1'b1;		// parameter column_8 = 6'd11-1'b1;  //0.8ÂëÂÊ
parameter order = 7'd127-1'b1;
parameter state0 = 1'b0; parameter state1 = 1'b1;


reg[5:0] row_num;   // reg[5:0] column_num;//resetÊ±£¬Ñ¡ÔñºÏÊÊµÄĞĞ£¬ÁĞÊı
reg[5:0] count_row;	 // reg[4:0] count_col; // ĞĞÁĞ¼ÆÊıÆ÷
reg[6:0] count_127;
reg	coder_first;

always @ (posedge clk)  // ¼ÆÊıÆ÷ÔË×ª
	begin
	if (!reset)
		begin
		count_127 <= 7'd0;
		coder_first <= 1'b0;
		case (velocity)
		  2'b01 : 	//0.4ÂëÂÊ
			begin					
			count_row <= 6'd23;  // ¼õ·¨¼ÆÊıÆ÷
			row_num <= row_4;
			//column_num <= column_4;		
			end
		  2'b10 :  	//0.6ÂëÂÊ
			begin					
			count_row <= 6'd35;
			row_num <= row_6;
			//column_num <= column_6;	
			end
		  2'b11 :	//0.8ÂëÂÊ
			begin					
			count_row <= 6'd47;
			row_num <= row_8;
			//column_num <= column_8;	
			end	
		default :            // Ä¬ÈÏ0.4ÂëÂÊ
			begin					
			count_row <= 6'd23;
			row_num <= row_4;
			//column_num <= column_4;	
			end
		endcase	
	end
	else
		begin
		if(data_in_en)
			begin
			case (velocity)
			  2'b01 : 	//0.4ÂëÂÊ
				begin					
				if((count_row==6'd23)&&(count_127==0))
					begin
					coder_first<= 1'b1;
					end
				else
					begin
					coder_first<= 1'b0;
					end
				end
			  2'b10 :  	//0.6ÂëÂÊ
				begin					
				if((count_row==6'd35)&&(count_127==0))
					begin
					coder_first<= 1'b1;
					end
				else
					begin
					coder_first<= 1'b0;
					end
				end
			  2'b11 :	//0.8ÂëÂÊ
				begin					
				if((count_row==6'd47)&&(count_127==0))
					begin
					coder_first<= 1'b1;
					end
				else
					begin
					coder_first<= 1'b0;
					end
				end	
			default :            // Ä¬ÈÏ0.4ÂëÂÊ
				begin					
				if((count_row==6'd23)&&(count_127==0))
					begin
					coder_first<= 1'b1;
					end
				else
					begin
					coder_first<= 1'b0;
					end
				end
			endcase	
			
			if(count_127 == order)
				begin
				count_127 <= 7'd0;
				if(count_row == 6'd0)
					begin
					count_row <= row_num;
					end
				else
					begin
					count_row <= count_row - 1'b1;
					end	
				end
			else
				begin
				count_127 <= count_127 + 1'b1;
				end	
			end			
		end
	end


reg	bit_in, bit_in_en;
reg[34:0] media_en;
reg[34:0] media_en0;
reg state;
reg[9:0]	address_04;
reg[9:0]	address_06;
reg[9:0]	address_08;

always @(posedge clk)   // ¿ØÖÆ¸öÔËËãÄ£¿é³õÊ¼»¯µÈ
	begin
	if (!reset)
		begin
		//coder_first <= 1'b0;
		bit_in	<= 1'b0; bit_in_en <= 1'b0;
		media_en <= 35'b00000_0000000000_0000000000_0000000001;     // ³õÊ¼»¯Ê±¾ÍĞ´ÈëµÚÒ»¸ömedia
		address_04 <= 10'd0; address_06 <= 10'd0; address_08 <= 10'd0;
		state <= state0;
		end
	else 
		begin
		case (velocity)
			2'b01 :  // 0.4 ÂëÂÊ
			begin
			bit_in	<= data_in; bit_in_en <= data_in_en;   // ÊäÈëÊı¾İ
			if(data_in_en)
				begin
				case (state)
					state0 :   //Ç°35¸ö·ûºÅ£¬ĞèÒª°´Ë³Ğò¶ÔmediaĞ´³õÊ¼ĞÅÏ¢
					begin
					if(media_en == 35'b10000_0000000000_0000000000_0000000000)
						begin
						state <= state1;
						media_en <= 35'd0;
						if(count_row == 0)   //×îºóÒ»ĞĞ×îºóÒ»¸ö¾ØĞÅÏ¢£¬¸´Î»romµØÖ·
							begin
							address_04 <= 10'd0;
							end
						else
							begin
							address_04 <= address_04+1'b1;
							end	
						end	
					else
						begin		
						address_04 <= address_04+1'b1;                 // ×´Ì¬µØÖ·ÀÛ¼Ó
						media_en <= media_en << 1;                        //°´Ë³Ğò¸ü¸Ä35¸öÔËËãÄ£¿éµÄmedia_en£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						end											
					end
					state1 :   // ºóÃæÊäÈëÊı¾İ£¬Ñ­»·ÔËËã¼´¿É£¬²»ĞèĞ´¾ØÕó³õÊ¼ĞÅÏ¢
					begin					
					if(count_127 == order)
						begin
						media_en <= 35'b00000_0000000000_0000000000_0000000001; //ÓëµÚ127¸öÊı¾İÊäÈëÍ¬Ê±£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						state <= state0;                                      
						end		
					end
				endcase
				end
			end
			
			2'b10 : // 0.6ÂëÂÊ
			begin
			bit_in	<= data_in; bit_in_en <= data_in_en;   // ÊäÈëÊı¾İ
			if(data_in_en)
				begin
				
				case (state)
					state0 :   //Ç°23¸ö·ûºÅ£¬ĞèÒª°´Ë³Ğò¶ÔmediaĞ´³õÊ¼ĞÅÏ¢
					begin
					if(media_en == 35'b00000_0000000100_0000000000_0000000000)
						begin
						state <= state1;
						media_en <= 35'd0;
						if(count_row == 0)   //×îºóÒ»ĞĞ×îºóÒ»¸ö¾ØĞÅÏ¢£¬¸´Î»romµØÖ·
							begin
							address_06 <= 10'd0;
							end
						else
							begin
							address_06 <= address_06+1'b1;
							end	
						end	
					else
						begin		
						address_06 <= address_06+1'b1;                 // ×´Ì¬µØÖ·ÀÛ¼Ó
						media_en <= media_en << 1;                        //°´Ë³Ğò¸ü¸Ä35¸öÔËËãÄ£¿éµÄmedia_en£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						end											
					end
					state1 :   // ºóÃæÊäÈëÊı¾İ£¬Ñ­»·ÔËËã¼´¿É£¬²»ĞèĞ´¾ØÕó³õÊ¼ĞÅÏ¢
					begin					
					if(count_127 == order)
						begin
						media_en <= 35'b00000_0000000000_0000000000_0000000001; //ÓëµÚ127¸öÊı¾İÊäÈëÍ¬Ê±£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						state <= state0;                                      
						end		
					end
				endcase
				end
			end
						
			2'b11 :
			begin
			bit_in	<= data_in; bit_in_en <= data_in_en;   // ÊäÈëÊı¾İ
			if(data_in_en)
				begin

				case (state)
					state0 :   //Ç°35¸ö·ûºÅ£¬ĞèÒª°´Ë³Ğò¶ÔmediaĞ´³õÊ¼ĞÅÏ¢
					begin
					if(media_en == 35'b00000_000000000_0000000001_0000000000)
						begin
						state <= state1;
						media_en <= 35'd0;
						if(count_row == 0)   //×îºóÒ»ĞĞ×îºóÒ»¸ö¾ØĞÅÏ¢£¬¸´Î»romµØÖ·
							begin
							address_08 <= 10'd0;
							end
						else
							begin
							address_08 <= address_08+1'b1;
							end	
						end	
					else
						begin		
						address_08 <= address_08+1'b1;                 // ×´Ì¬µØÖ·ÀÛ¼Ó
						media_en <= media_en << 1;                        //°´Ë³Ğò¸ü¸Ä35¸öÔËËãÄ£¿éµÄmedia_en£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						end											
					end
					state1 :   // ºóÃæÊäÈëÊı¾İ£¬Ñ­»·ÔËËã¼´¿É£¬²»ĞèĞ´¾ØÕó³õÊ¼ĞÅÏ¢
					begin					
					if(count_127 == order)
						begin
						media_en <= 35'b00000_0000000000_0000000000_0000000001; //ÓëµÚ127¸öÊı¾İÊäÈëÍ¬Ê±£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						state <= state0;                                      
						end		
					end
				endcase
				end
			end		
			default :
				begin
				bit_in	<= data_in; bit_in_en <= data_in_en;   // ÊäÈëÊı¾İ
				if(data_in_en)
					begin
					case (state)
						state0 :   //Ç°35¸ö·ûºÅ£¬ĞèÒª°´Ë³Ğò¶ÔmediaĞ´³õÊ¼ĞÅÏ¢
						begin
						if(media_en == 35'b10000_0000000000_0000000000_0000000000)
							begin
							state <= state1;
							media_en <= 35'd0;
							if(count_row == 0)   //×îºóÒ»ĞĞ×îºóÒ»¸ö¾ØĞÅÏ¢£¬¸´Î»romµØÖ·
								begin
								address_04 <= 9'd0;
								end
							else
								begin
								address_04 <= address_04+1'b1;
								end	
							end	
						else
							begin		
							address_04 <= address_04+1'b1;                 // ×´Ì¬µØÖ·ÀÛ¼Ó
							media_en <= media_en << 1;                        //°´Ë³Ğò¸ü¸Ä35¸öÔËËãÄ£¿éµÄmedia_en£¬Ğ´Èë³õÊ¼ĞÅÏ¢
							end											
						end
						state1 :   // ºóÃæÊäÈëÊı¾İ£¬Ñ­»·ÔËËã¼´¿É£¬²»ĞèĞ´¾ØÕó³õÊ¼ĞÅÏ¢
						begin					
						if(count_127 == order)
							begin
							media_en <= 35'b00000_0000000000_0000000000_0000000001; //ÓëµÚ127¸öÊı¾İÊäÈëÍ¬Ê±£¬Ğ´Èë³õÊ¼ĞÅÏ¢
							state <= state0;                                      
							end		
						end
					endcase
					end
				end
		endcase
		end
	end

reg[126:0] rom_data;

always @(posedge clk)
begin
	case (velocity)
	2'b01 : 	//0.4ÂëÂÊ
		begin					
        rom_data<=rom_data04;
		end
	2'b10 :  	//0.6ÂëÂÊ
		begin					
		rom_data<=rom_data06;
		end
	 2'b11 :	//0.8ÂëÂÊ
		begin					
		rom_data<=rom_data08;
		end	
	default :            // Ä¬ÈÏ0.4ÂëÂÊ
		begin					
		rom_data<=rom_data04;
		end
	endcase	
end



reg[6:0] count;
reg[126:0] wr_data;
reg[125:0] data;
reg  wr_en;

always @(posedge clk)   // ´®²¢×ª»»Êı¾İÎ»£¬´æÈëfifo
	begin
	if(!reset)
		begin
		count<=7'd0;
		data<=126'd0;
		wr_data<=126'd0;
		wr_en<=1'b0;
		end
	else
		begin
		case (velocity)
		  2'b01 : 	//0.4ÂëÂÊ
			begin					
			if(en_media34==1)
				begin
				if(count==126)
					begin
					wr_data<={data[125:0],data_media34};
					wr_en<=1'b1;
					count<=7'd0;
					end
				else
					begin
					data<= {data[124:0],data_media34};
					wr_en<=1'b0;
					count<=count+1'b1;
					end
				end
			else
				begin
				wr_en<=1'b0;
				end		
			end
		  2'b10 :  	//0.6ÂëÂÊ
			begin					
			if(en_media22==1)
				begin
				if(count==126)
					begin
					wr_data<={data[125:0],data_media22};
					wr_en<=1'b1;
					count<=7'd0;
					end
				else
					begin
					data<= {data[124:0],data_media22};
					wr_en<=1'b0;
					count<=count+1'b1;
					end
				end
			else
				begin
				wr_en<=1'b0;
				end	
			end
		  2'b11 :	//0.8ÂëÂÊ
			begin					
			if(en_media10==1)
				begin
				if(count==126)
					begin
					wr_data<={data[125:0],data_media10};
					wr_en<=1'b1;
					count<=7'd0;
					end
				else
					begin
					data<= {data[124:0],data_media10};
					wr_en<=1'b0;
					count<=count+1'b1;
					end
				end
			else
				begin
				wr_en<=1'b0;
				end	
			end	
		default :            // Ä¬ÈÏ0.4ÂëÂÊ
			begin					
			if(en_media34==1)
				begin
				if(count==126)
					begin
					wr_data<={data[125:0],data_media34};
					wr_en<=1'b1;
					count<=7'd0;
					end
				else
					begin
					data<= {data[124:0],data_media34};
					wr_en<=1'b0;
					count<=count+1'b1;
					end
				end
			else
				begin
				wr_en<=1'b0;
				end		
			end		
		endcase
				
	end
end


reg[126:0] data_out;
reg  data_out_en,indication,rd_en;
wire[126:0] fifo_out;

always @(posedge clk)  //¿ØÖÆÊä³ö
	begin
	if(!reset)
		begin
		data_out <= 127'd0;
		data_out_en <= 1'b0;
		indication <= 1'b0;
		end
	else
		begin
		if(data_in_en)
			begin
			case (velocity)
			  2'b01 : 	//0.4ÂëÂÊ
				begin					
				if(count_row == 0) // ×îºóÒ»ĞĞÔËËã
					begin
					case (count_127)  // Êä³öĞ£ÑéÎ»
						7'd2 :	data_out <= data_0;		7'd12 : data_out <= data_10;	7'd22 : data_out <= data_20;	7'd32 : data_out <= data_30;
						7'd3 :	data_out <= data_1;		7'd13 : data_out <= data_11;	7'd23 : data_out <= data_21;	7'd33 : data_out <= data_31;
						7'd4 :	data_out <= data_2;		7'd14 : data_out <= data_12;	7'd24 : data_out <= data_22;	7'd34 : data_out <= data_32;
						7'd5 :	data_out <= data_3;		7'd15 : data_out <= data_13;	7'd25 : data_out <= data_23;	7'd35 : data_out <= data_33;
						7'd6 :	data_out <= data_4;		7'd16 : data_out <= data_14;	7'd26 : data_out <= data_24;	7'd36 : data_out <= data_34;
						7'd7 : data_out <= data_5;		7'd17 : data_out <= data_15;	7'd27 : data_out <= data_25;
						7'd8 : data_out <= data_6;		7'd18 : data_out <= data_16;	7'd28 : data_out <= data_26;
						7'd9 : data_out <= data_7;		7'd19 : data_out <= data_17;	7'd29 : data_out <= data_27;
						7'd10 : data_out <= data_8;	7'd20 : data_out <= data_18;	7'd30 : data_out <= data_28;
						7'd11 : data_out <= data_9;	7'd21 : data_out <= data_19;	7'd31 : data_out <= data_29;
					endcase
					
					if(count_127==2) // Êä³öµÚÒ»¸ö127Ö¸Ê¾ĞÅºÅ
						begin
						indication <= 1'b1;
						end
					else
						begin
						indication <= 1'b0;
						end
						
					if((count_127>=34)&&(count_127<=58))  //·¢³ö¶ÁfifoÖ¸Áî
						begin
						rd_en<=1'b1;						
						end
					else
						begin
						rd_en<=1'b0;
						end	
						
					if((count_127>=36)&&(count_127<=60))  //¶ÁfifoÊä³ö£¬Êä³öÊı¾İÎ»
						begin
						data_out <= fifo_out;						
						end
						
					if((count_127>=2)&&(count_127<=60)) //Ê¹ÄÜĞÅºÅ
						begin
						data_out_en<=1'b1;
						end
					else
						begin
						data_out_en<=1'b0;
						end	
					end
				else
					begin
					indication<= 1'b0;
					data_out_en<=1'b0;
					rd_en<=1'b0;
					end
				end
			  2'b10 :  	//0.6ÂëÂÊ
				begin					
				if(count_row == 0) // ×îºóÒ»ĞĞÔËËã
					begin
					case (count_127)  // Êä³öĞ£ÑéÎ»
						7'd2 :	data_out <= data_0;		7'd12 : data_out <= data_10;	7'd22 : data_out <= data_20;	//32 : data_out <= data_30;
						7'd3 :	data_out <= data_1;		7'd13 : data_out <= data_11;	7'd23 : data_out <= data_21;	//33 : data_out <= data_31;
						7'd4 :	data_out <= data_2;		7'd14 : data_out <= data_12;	7'd24 : data_out <= data_22;	//34 : data_out <= data_32;
						7'd5 :	data_out <= data_3;		7'd15 : data_out <= data_13;	//25 : data_out <= data_23;	35 : data_out <= data_33;
						7'd6 :	data_out <= data_4;		7'd16 : data_out <= data_14;	//26 : data_out <= data_24;	36 : data_out <= data_34;
						7'd7 : data_out <= data_5;		7'd17 : data_out <= data_15;	//27 : data_out <= data_25;
						7'd8 : data_out <= data_6;		7'd18 : data_out <= data_16;	//28 : data_out <= data_26;
						7'd9 : data_out <= data_7;		7'd19 : data_out <= data_17;	//29 : data_out <= data_27;
						7'd10 : data_out <= data_8;	7'd20 : data_out <= data_18;	//30 : data_out <= data_28;
						7'd11 : data_out <= data_9;	7'd21 : data_out <= data_19;	//31 : data_out <= data_29;
					endcase
					
					if(count_127==7'd2) // Êä³öµÚÒ»¸ö127Ö¸Ê¾ĞÅºÅ
						begin
						indication <= 1'b1;
						end
					else
						begin
						indication <= 1'b0;
						end
						
					if((count_127>=7'd23)&&(count_127<=7'd58))  //·¢³ö¶ÁfifoÖ¸Áî
						begin
						rd_en<=1'b1;						
						end
					else
						begin
						rd_en<=1'b0;
						end	
						
					if((count_127>=7'd25)&&(count_127<=7'd60))  //¶ÁfifoÊä³ö£¬Êä³öÊı¾İÎ»
						begin
						data_out <= fifo_out;						
						end
						
					if((count_127>=7'd2)&&(count_127<=7'd60)) //Ê¹ÄÜĞÅºÅ
						begin
						data_out_en<=1'b1;
						end
					else
						begin
						data_out_en<=1'b0;
						end	
					end
				else
					begin
					indication<= 1'b0;
					data_out_en<=1'b0;
					rd_en<=1'b0;
					end
				end
			  2'b11 :	//0.8ÂëÂÊ
				begin					
				if(count_row == 0) // ×îºóÒ»ĞĞÔËËã
					begin
					case (count_127)  // Êä³öĞ£ÑéÎ»
						7'd2 :	data_out <= data_0;		//12 : data_out <= data_10;	22 : data_out <= data_20;	//32 : data_out <= data_30;
						7'd3 :	data_out <= data_1;		//13 : data_out <= data_11;	23 : data_out <= data_21;	//33 : data_out <= data_31;
						7'd4 :	data_out <= data_2;		//14 : data_out <= data_12;	24 : data_out <= data_22;	//34 : data_out <= data_32;
						7'd5 :	data_out <= data_3;		//15 : data_out <= data_13;	//25 : data_out <= data_23;	35 : data_out <= data_33;
						7'd6 :	data_out <= data_4;		//16 : data_out <= data_14;	//26 : data_out <= data_24;	36 : data_out <= data_34;
						7'd7 : data_out <= data_5;		//17 : data_out <= data_15;	//27 : data_out <= data_25;
						7'd8 : data_out <= data_6;		//18 : data_out <= data_16;	//28 : data_out <= data_26;
						7'd9 : data_out <= data_7;		//19 : data_out <= data_17;	//29 : data_out <= data_27;
						7'd10 : data_out <= data_8;	//20 : data_out <= data_18;	//30 : data_out <= data_28;
						//11 : data_out <= data_9;	21 : data_out <= data_19;	//31 : data_out <= data_29;
					endcase
					
					if(count_127==7'd2) // Êä³öµÚÒ»¸ö127Ö¸Ê¾ĞÅºÅ
						begin
						indication <= 1'b1;
						end
					else
						begin
						indication <= 1'b0;
						end
						
					if((count_127>=7'd9)&&(count_127<=7'd58))  //·¢³ö¶ÁfifoÖ¸Áî
						begin
						rd_en<=1'b1;						
						end
					else
						begin
						rd_en<=1'b0;
						end	
						
					if((count_127>=7'd11)&&(count_127<=7'd60))  //¶ÁfifoÊä³ö£¬Êä³öÊı¾İÎ»
						begin
						data_out <= fifo_out;						
						end
						
					if((count_127>=7'd2)&&(count_127<=7'd60)) //Ê¹ÄÜĞÅºÅ
						begin
						data_out_en<=1'b1;
						end
					else
						begin
						data_out_en<=1'b0;
						end	
					end
				else
					begin
					indication<= 1'b0;
					data_out_en<=1'b0;
					rd_en<=1'b0;
					end
				end
			default :            // Ä¬ÈÏ0.4ÂëÂÊ
				begin					
				if(count_row == 0) // ×îºóÒ»ĞĞÔËËã
					begin
					case (count_127)  // Êä³öĞ£ÑéÎ»
						7'd2 :	data_out <= data_0;		7'd12 : data_out <= data_10;	7'd22 : data_out <= data_20;	7'd32 : data_out <= data_30;
						7'd3 :	data_out <= data_1;		7'd13 : data_out <= data_11;	7'd23 : data_out <= data_21;	7'd33 : data_out <= data_31;
						7'd4 :	data_out <= data_2;		7'd14 : data_out <= data_12;	7'd24 : data_out <= data_22;	7'd34 : data_out <= data_32;
						7'd5 :	data_out <= data_3;		7'd15 : data_out <= data_13;	7'd25 : data_out <= data_23;	7'd35 : data_out <= data_33;
						7'd6 :	data_out <= data_4;		7'd16 : data_out <= data_14;	7'd26 : data_out <= data_24;	7'd36 : data_out <= data_34;
						7'd7 : data_out <= data_5;		7'd17 : data_out <= data_15;	7'd27 : data_out <= data_25;
						7'd8 : data_out <= data_6;		7'd18 : data_out <= data_16;	7'd28 : data_out <= data_26;
						7'd9 : data_out <= data_7;		7'd19 : data_out <= data_17;	7'd29 : data_out <= data_27;
						7'd10 : data_out <= data_8;	7'd20 : data_out <= data_18;	7'd30 : data_out <= data_28;
						7'd11 : data_out <= data_9;	7'd21 : data_out <= data_19;	7'd31 : data_out <= data_29;
					endcase
					
					if(count_127==2) // Êä³öµÚÒ»¸ö127Ö¸Ê¾ĞÅºÅ
						begin
						indication <= 1'b1;
						end
					else
						begin
						indication <= 1'b0;
						end
						
					if((count_127>=34)&&(count_127<=58))  //·¢³ö¶ÁfifoÖ¸Áî
						begin
						rd_en<=1'b1;						
						end
					else
						begin
						rd_en<=1'b0;
						end	
						
					if((count_127>=36)&&(count_127<=60))  //¶ÁfifoÊä³ö£¬Êä³öÊı¾İÎ»
						begin
						data_out <= fifo_out;						
						end
						
					if((count_127>=2)&&(count_127<=60)) //Ê¹ÄÜĞÅºÅ
						begin
						data_out_en<=1'b1;
						end
					else
						begin
						data_out_en<=1'b0;
						end	
					end
				else
					begin
					indication<= 1'b0;
					data_out_en<=1'b0;
					rd_en<=1'b0;
					end
				end
			endcase	
			end
		end		
	end
	
wire[126:0] rom_data04; 
wire[126:0] rom_data06;
wire[126:0] rom_data08; 

wire data_media0,data_media1,data_media2,data_media3,data_media4,data_media5,data_media6,data_media7,data_media8,data_media9,
	 data_media10,data_media11,data_media12,data_media13,data_media14,data_media15,data_media16,data_media17,data_media18,data_media19,
	 data_media20,data_media21,data_media22,data_media23,data_media24,data_media25,data_media26,data_media27,data_media28,data_media29,
	 data_media30,data_media31,data_media32,data_media33,data_media34;  // Êı¾İ
wire en_media0,en_media1,en_media2,en_media3,en_media4,en_media5,en_media6,en_media7,en_media8,en_media9,
	 en_media10,en_media11,en_media12,en_media13,en_media14,en_media15,en_media16,en_media17,en_media18,en_media19,
	 en_media20,en_media21,en_media22,en_media23,en_media24,en_media25,en_media26,en_media27,en_media28,en_media29,
	 en_media30,en_media31,en_media32,en_media33,en_media34;  // Á¬½Óbit_en
wire first_media0,first_media1,first_media2,first_media3,first_media4,first_media5,first_media6,first_media7,first_media8,first_media9,
	 first_media10,first_media11,first_media12,first_media13,first_media14,first_media15,first_media16,first_media17,first_media18,first_media19,
	 first_media20,first_media21,first_media22,first_media23,first_media24,first_media25,first_media26,first_media27,first_media28,first_media29,
	 first_media30,first_media31,first_media32,first_media33,first_media34;
wire[126:0] data_0,data_1,data_2,data_3,data_4,data_5,data_6,data_7,data_8,data_9,
	 data_10,data_11,data_12,data_13,data_14,data_15,data_16,data_17,data_18,data_19,
	 data_20,data_21,data_22,data_23,data_24,data_25,data_26,data_27,data_28,data_29,
	 data_30,data_31,data_32,data_33,data_34;	
	
matrix_op     m0( .clk(clk),.reset(reset),.bit_in(bit_in),.bit_in_en(bit_in_en), .media_in(rom_data),.media_in_en(media_en[0]),
	  .coder_first(coder_first),.bit_out(data_media0),.bit_out_en(en_media0), .first_out(first_media0),.data_out(data_0));	
matrix_op     m1( .clk(clk),.reset(reset),.bit_in(data_media0),.bit_in_en(en_media0), .media_in(rom_data),.media_in_en(media_en[1]),
	  .coder_first(first_media0),.bit_out(data_media1),.bit_out_en(en_media1), .first_out(first_media1),.data_out(data_1));	
matrix_op     m2( .clk(clk),.reset(reset),.bit_in(data_media1),.bit_in_en(en_media1), .media_in(rom_data),.media_in_en(media_en[2]),
	  .coder_first(first_media1),.bit_out(data_media2),.bit_out_en(en_media2), .first_out(first_media2),.data_out(data_2) );	
matrix_op     m3( .clk(clk),.reset(reset),.bit_in(data_media2),.bit_in_en(en_media2), .media_in(rom_data),.media_in_en(media_en[3]),
	  .coder_first(first_media2),.bit_out(data_media3),.bit_out_en(en_media3), .first_out(first_media3),.data_out(data_3) );	
matrix_op     m4( .clk(clk),.reset(reset),.bit_in(data_media3),.bit_in_en(en_media3), .media_in(rom_data),.media_in_en(media_en[4]),
	  .coder_first(first_media3),.bit_out(data_media4),.bit_out_en(en_media4), .first_out(first_media4),.data_out(data_4) );	
matrix_op     m5( .clk(clk),.reset(reset),.bit_in(data_media4),.bit_in_en(en_media4), .media_in(rom_data),.media_in_en(media_en[5]),
	  .coder_first(first_media4),.bit_out(data_media5),.bit_out_en(en_media5), .first_out(first_media5),.data_out(data_5) );	
matrix_op     m6( .clk(clk),.reset(reset),.bit_in(data_media5),.bit_in_en(en_media5), .media_in(rom_data),.media_in_en(media_en[6]),
	  .coder_first(first_media5),.bit_out(data_media6),.bit_out_en(en_media6), .first_out(first_media6),.data_out(data_6));	
matrix_op     m7( .clk(clk),.reset(reset),.bit_in(data_media6),.bit_in_en(en_media6), .media_in(rom_data),.media_in_en(media_en[7]),
	  .coder_first(first_media6),.bit_out(data_media7),.bit_out_en(en_media7), .first_out(first_media7),.data_out(data_7) );	
matrix_op     m8( .clk(clk),.reset(reset),.bit_in(data_media7),.bit_in_en(en_media7), .media_in(rom_data),.media_in_en(media_en[8]),
	  .coder_first(first_media7),.bit_out(data_media8),.bit_out_en(en_media8), .first_out(first_media8),.data_out(data_8));	
matrix_op      m9( .clk(clk),.reset(reset),.bit_in(data_media8),.bit_in_en(en_media8), .media_in(rom_data),.media_in_en(media_en[9]),
	  .coder_first(first_media8),.bit_out(data_media9),.bit_out_en(en_media9), .first_out(first_media9),.data_out(data_9));	
matrix_op      m10( .clk(clk),.reset(reset),.bit_in(data_media9),.bit_in_en(en_media9), .media_in(rom_data),.media_in_en(media_en[10]),
  .coder_first(first_media9),.bit_out(data_media10),.bit_out_en(en_media10), .first_out(first_media10),.data_out(data_10) );	
matrix_op      m11( .clk(clk),.reset(reset),.bit_in(data_media10),.bit_in_en(en_media10), .media_in(rom_data),.media_in_en(media_en[11]),
  .coder_first(first_media10),.bit_out(data_media11),.bit_out_en(en_media11), .first_out(first_media11),.data_out(data_11) );	
matrix_op      m12( .clk(clk),.reset(reset),.bit_in(data_media11),.bit_in_en(en_media11), .media_in(rom_data),.media_in_en(media_en[12]),
  .coder_first(first_media11),.bit_out(data_media12),.bit_out_en(en_media12), .first_out(first_media12),.data_out(data_12) );	
matrix_op      m13( .clk(clk),.reset(reset),.bit_in(data_media12),.bit_in_en(en_media12), .media_in(rom_data),.media_in_en(media_en[13]),
  .coder_first(first_media12),.bit_out(data_media13),.bit_out_en(en_media13), .first_out(first_media13),.data_out(data_13) );	
matrix_op      m14( .clk(clk),.reset(reset),.bit_in(data_media13),.bit_in_en(en_media13), .media_in(rom_data),.media_in_en(media_en[14]),
  .coder_first(first_media13),.bit_out(data_media14),.bit_out_en(en_media14), .first_out(first_media14),.data_out(data_14) );	
matrix_op      m15( .clk(clk),.reset(reset),.bit_in(data_media14),.bit_in_en(en_media14), .media_in(rom_data),.media_in_en(media_en[15]),
  .coder_first(first_media14),.bit_out(data_media15),.bit_out_en(en_media15), .first_out(first_media15),.data_out(data_15) );	
matrix_op      m16( .clk(clk),.reset(reset),.bit_in(data_media15),.bit_in_en(en_media15), .media_in(rom_data),.media_in_en(media_en[16]),
  .coder_first(first_media15),.bit_out(data_media16),.bit_out_en(en_media16), .first_out(first_media16),.data_out(data_16) );	
matrix_op      m17( .clk(clk),.reset(reset),.bit_in(data_media16),.bit_in_en(en_media16), .media_in(rom_data),.media_in_en(media_en[17]),
  .coder_first(first_media16),.bit_out(data_media17),.bit_out_en(en_media17), .first_out(first_media17),.data_out(data_17) );	
matrix_op      m18( .clk(clk),.reset(reset),.bit_in(data_media17),.bit_in_en(en_media17), .media_in(rom_data),.media_in_en(media_en[18]),
  .coder_first(first_media17),.bit_out(data_media18),.bit_out_en(en_media18), .first_out(first_media18),.data_out(data_18) );	
matrix_op      m19( .clk(clk),.reset(reset),.bit_in(data_media18),.bit_in_en(en_media18), .media_in(rom_data),.media_in_en(media_en[19]),
  .coder_first(first_media18),.bit_out(data_media19),.bit_out_en(en_media19), .first_out(first_media19),.data_out(data_19) );	
matrix_op      m20( .clk(clk),.reset(reset),.bit_in(data_media19),.bit_in_en(en_media19), .media_in(rom_data),.media_in_en(media_en[20]),
  .coder_first(first_media19),.bit_out(data_media20),.bit_out_en(en_media20), .first_out(first_media20),.data_out(data_20) );	
matrix_op      m21( .clk(clk),.reset(reset),.bit_in(data_media20),.bit_in_en(en_media20), .media_in(rom_data),.media_in_en(media_en[21]),
  .coder_first(first_media20),.bit_out(data_media21),.bit_out_en(en_media21), .first_out(first_media21),.data_out(data_21) );	
matrix_op      m22( .clk(clk),.reset(reset),.bit_in(data_media21),.bit_in_en(en_media21), .media_in(rom_data),.media_in_en(media_en[22]),
  .coder_first(first_media21),.bit_out(data_media22),.bit_out_en(en_media22), .first_out(first_media22),.data_out(data_22));	
matrix_op      m23( .clk(clk),.reset(reset),.bit_in(data_media22),.bit_in_en(en_media22), .media_in(rom_data),.media_in_en(media_en[23]),
  .coder_first(first_media22),.bit_out(data_media23),.bit_out_en(en_media23), .first_out(first_media23),.data_out(data_23));	
matrix_op      m24( .clk(clk),.reset(reset),.bit_in(data_media23),.bit_in_en(en_media23), .media_in(rom_data),.media_in_en(media_en[24]),
  .coder_first(first_media23),.bit_out(data_media24),.bit_out_en(en_media24), .first_out(first_media24),.data_out(data_24));	
matrix_op      m25( .clk(clk),.reset(reset),.bit_in(data_media24),.bit_in_en(en_media24), .media_in(rom_data),.media_in_en(media_en[25]),
  .coder_first(first_media24),.bit_out(data_media25),.bit_out_en(en_media25), .first_out(first_media25),.data_out(data_25));	
matrix_op      m26( .clk(clk),.reset(reset),.bit_in(data_media25),.bit_in_en(en_media25), .media_in(rom_data),.media_in_en(media_en[26]),
  .coder_first(first_media25),.bit_out(data_media26),.bit_out_en(en_media26), .first_out(first_media26),.data_out(data_26) );	
matrix_op      m27( .clk(clk),.reset(reset),.bit_in(data_media26),.bit_in_en(en_media26), .media_in(rom_data),.media_in_en(media_en[27]),
  .coder_first(first_media26),.bit_out(data_media27),.bit_out_en(en_media27), .first_out(first_media27),.data_out(data_27));	
matrix_op      m28( .clk(clk),.reset(reset),.bit_in(data_media27),.bit_in_en(en_media27), .media_in(rom_data),.media_in_en(media_en[28]),
  .coder_first(first_media27),.bit_out(data_media28),.bit_out_en(en_media28), .first_out(first_media28),.data_out(data_28));	
matrix_op      m29( .clk(clk),.reset(reset),.bit_in(data_media28),.bit_in_en(en_media28), .media_in(rom_data),.media_in_en(media_en[29]),
  .coder_first(first_media28),.bit_out(data_media29),.bit_out_en(en_media29), .first_out(first_media29),.data_out(data_29));	
matrix_op      m30( .clk(clk),.reset(reset),.bit_in(data_media29),.bit_in_en(en_media29), .media_in(rom_data),.media_in_en(media_en[30]),
  .coder_first(first_media29),.bit_out(data_media30),.bit_out_en(en_media30), .first_out(first_media30),.data_out(data_30));	
matrix_op      m31( .clk(clk),.reset(reset),.bit_in(data_media30),.bit_in_en(en_media30), .media_in(rom_data),.media_in_en(media_en[31]),
  .coder_first(first_media30),.bit_out(data_media31),.bit_out_en(en_media31), .first_out(first_media31),.data_out(data_31) );	
matrix_op      m32( .clk(clk),.reset(reset),.bit_in(data_media31),.bit_in_en(en_media31), .media_in(rom_data),.media_in_en(media_en[32]),
  .coder_first(first_media31),.bit_out(data_media32),.bit_out_en(en_media32), .first_out(first_media32),.data_out(data_32) );	
matrix_op      m33( .clk(clk),.reset(reset),.bit_in(data_media32),.bit_in_en(en_media32), .media_in(rom_data),.media_in_en(media_en[33]),
  .coder_first(first_media32),.bit_out(data_media33),.bit_out_en(en_media33), .first_out(first_media33),.data_out(data_33) );	
matrix_op      m34( .clk(clk),.reset(reset),.bit_in(data_media33),.bit_in_en(en_media33), .media_in(rom_data),.media_in_en(media_en[34]),
  .coder_first(first_media33),.bit_out(data_media34),.bit_out_en(en_media34), .first_out(first_media34),.data_out(data_34) );	


altsyncram	altsyncram_component_04 (
				.clock0 (clk),
				.address_a (address_04),
				.q_a (rom_data04),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.q_b (),
				.clocken1 (1'b1),
				.clocken0 (1'b1),
				.data_b (1'b1),
				.wren_a (1'b0),
				.data_a ({127{1'b1}}),
				.rden_b (1'b1),
				.address_b (1'b1),
				.wren_b (1'b0),
				.byteena_b (1'b1),
				.addressstall_a (1'b0),
				.byteena_a (1'b1),
				.addressstall_b (1'b0),
				.clock1 (1'b1));
	defparam
		altsyncram_component_04.address_aclr_a = "NONE",
		altsyncram_component_04.init_file = "0.4×ª»»¾Ø.mif",
		altsyncram_component_04.intended_device_family = "Stratix",
		altsyncram_component_04.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component_04.lpm_type = "altsyncram",
		altsyncram_component_04.numwords_a = 840,
		altsyncram_component_04.operation_mode = "ROM",
		altsyncram_component_04.outdata_aclr_a = "NONE",
		altsyncram_component_04.outdata_reg_a = "CLOCK0",
		altsyncram_component_04.widthad_a = 10,
		altsyncram_component_04.width_a = 127,
		altsyncram_component_04.width_byteena_a = 1;
		
altsyncram	altsyncram_component_06 (
				.clock0 (clk),
				.address_a (address_06),
				.q_a (rom_data06),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.q_b (),
				.clocken1 (1'b1),
				.clocken0 (1'b1),
				.data_b (1'b1),
				.wren_a (1'b0),
				.data_a ({127{1'b1}}),
				.rden_b (1'b1),
				.address_b (1'b1),
				.wren_b (1'b0),
				.byteena_b (1'b1),
				.addressstall_a (1'b0),
				.byteena_a (1'b1),
				.addressstall_b (1'b0),
				.clock1 (1'b1));
	defparam
		altsyncram_component_06.address_aclr_a = "NONE",
		altsyncram_component_06.init_file = "0.6×ª»»¾Ø.mif",
		altsyncram_component_06.intended_device_family = "Stratix",
		altsyncram_component_06.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component_06.lpm_type = "altsyncram",
		altsyncram_component_06.numwords_a = 828,
		altsyncram_component_06.operation_mode = "ROM",
		altsyncram_component_06.outdata_aclr_a = "NONE",
		altsyncram_component_06.outdata_reg_a = "CLOCK0",
		altsyncram_component_06.widthad_a = 10,
		altsyncram_component_06.width_a = 127,
		altsyncram_component_06.width_byteena_a = 1;
		
		altsyncram	altsyncram_component_08 (
				.clock0 (clk),
				.address_a (address_08),
				.q_a (rom_data08),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.q_b (),
				.clocken1 (1'b1),
				.clocken0 (1'b1),
				.data_b (1'b1),
				.wren_a (1'b0),
				.data_a ({127{1'b1}}),
				.rden_b (1'b1),
				.address_b (1'b1),
				.wren_b (1'b0),
				.byteena_b (1'b1),
				.addressstall_a (1'b0),
				.byteena_a (1'b1),
				.addressstall_b (1'b0),
				.clock1 (1'b1));
	defparam
		altsyncram_component_08.address_aclr_a = "NONE",
		altsyncram_component_08.init_file = "0.8×ª»»¾Ø.mif",
		altsyncram_component_08.intended_device_family = "Stratix",
		altsyncram_component_08.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component_08.lpm_type = "altsyncram",
		altsyncram_component_08.numwords_a = 528,
		altsyncram_component_08.operation_mode = "ROM",
		altsyncram_component_08.outdata_aclr_a = "NONE",
		altsyncram_component_08.outdata_reg_a = "CLOCK0",
		altsyncram_component_08.widthad_a = 10,
		altsyncram_component_08.width_a = 127,
		altsyncram_component_08.width_byteena_a = 1;
		
scfifo	scfifo_component (
				.rdreq (rd_en),
				.clock (clk),
				.wrreq (wr_en),
				.data (wr_data),
				.q (fifo_out)
				// synopsys translate_off
				,
				.usedw (),
				.almost_empty (),
				.sclr (),
				.almost_full (),
				.aclr (),
				.empty (),
				.full ()
				// synopsys translate_on
				);
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.intended_device_family = "Stratix",
		scfifo_component.lpm_numwords = 64,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = 127,
		scfifo_component.lpm_widthu = 6,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";


endmodule




















module LDPC	(clk,reset,
			 data_in, 
			data_in_en,//ÊäÈëÊ¹ÄÜ¶Ë 	
			 velocity, /*ÊäÈëĞÅºÅÂëÂÊÑ¡Ôñ*/
		    data_out, 
			data_out_en,//Êä³öÊ¹ÄÜ¶Ë
			 indication /*Êä³öĞÅºÅ£¬µÚÒ»¸ö127ÒªÉ¾³ıÇ°5³É7488£¬Ö¸Ê¾µÚÒ»¸ö127*/
				);
				

input	clk,reset;
input	data_in,data_in_en;
input[1:0]	velocity; //Ñ¡ÔñÂëÂÊĞÅºÅ
output[126:0]	data_out;//Êä³öĞÅºÅ
output	data_out_en;
output	indication;


parameter row_4 = 6'd24-1'b1;  //ĞÅÏ¢ÂëÁ÷±»·Ö³É24¶Î£¬Ã¿¶ÎÓĞ127bit // parameter column_4 = 6'd35-1'b1;  //0.4ÂëÂÊ
parameter row_6 = 6'd36-1'b1;  //ĞÅÏ¢ÂëÁ÷// parameter column_6 = 6'd23-1'b1;  //0.6ÂëÂÊ
parameter row_8 = 6'd48-1'b1;  //ĞÅÏ¢Âë²¿¢// parameter column_8 = 6'd11-1'b1;  //0.8ÂëÂÊ
parameter order = 7'd127-1'b1;
parameter state0 = 1'b0; parameter state1 = 1'b1;


reg[5:0] row_num;   // reg[5:0] column_num;//resetÊ±£¬Ñ¡ÔñºÏÊÊµÄĞĞ£¬ÁĞÊı
reg[5:0] count_row;	 // reg[4:0] count_col; // ĞĞÁĞ¼ÆÊıÆ÷
reg[6:0] count_127;
reg	coder_first;
//¿¼ÂÇÓ²¼şµÄÊµ¼ÊÇé¿ö£¬Ã¿6¸öbit´«³ö



always @ (posedge clk)  // ¼ÆÊıÆ÷ÔË×ª
	begin
	if (!reset)
		begin
		count_127 <= 7'd0;
		coder_first <= 1'b0;
		case (velocity)
		  2'b01 : 	//0.4ÂëÂÊ
			begin					
			count_row <= 6'd23;  // ¼õ·¨¼ÆÊıÆ÷
			row_num <= row_4;
			//column_num <= column_4;		
			end
		  2'b10 :  	//0.6ÂëÂÊ
			begin					
			count_row <= 6'd35;
			row_num <= row_6;
			//column_num <= column_6;	
			end
		  2'b11 :	//0.8ÂëÂÊ
			begin					
			count_row <= 6'd47;
			row_num <= row_8;
			//column_num <= column_8;	
			end	
		default :            // Ä¬ÈÏ0.4ÂëÂÊ
			begin					
			count_row <= 6'd23;
			row_num <= row_4;
			//column_num <= column_4;	
			end
		endcase	
	    end
	else
		begin
		if(data_in_en)
			begin
			case (velocity)
			  2'b01 : 	//0.4ÂëÂÊ
				begin					
				if((count_row==6'd23)&&(count_127==0))
					begin
					coder_first<= 1'b1;
					end
				else
					begin
					coder_first<= 1'b0;
					end
				end
			  2'b10 :  	//0.6ÂëÂÊ
				begin					
				if((count_row==6'd35)&&(count_127==0))
					begin
					coder_first<= 1'b1;
					end
				else
					begin
					coder_first<= 1'b0;
					end
				end
			  2'b11 :	//0.8ÂëÂÊ
				begin					
				if((count_row==6'd47)&&(count_127==0))
					begin
					coder_first<= 1'b1;
					end
				else
					begin
					coder_first<= 1'b0;
					end
				end	
			default :            // Ä¬ÈÏ0.4ÂëÂÊ
				begin					
				if((count_row==6'd23)&&(count_127==0))
					begin
					coder_first<= 1'b1;
					end
				else
					begin
					coder_first<= 1'b0;
					end
				end
			endcase	
			
			if(count_127 == order)
				begin
				count_127 <= 7'd0;
				if(count_row == 6'd0)
					begin
					count_row <= row_num;
					end
				else
					begin
					count_row <= count_row - 1'b1;
					end	
				end
			else
				begin
				count_127 <= count_127 + 1'b1;
				end	
			end			
		end
	end







reg	bit_in, bit_in_en;
reg[34:0] media_en;
reg[34:0] media_en0;
reg state;
reg[9:0]	address_04;
reg[9:0]	address_06;
reg[9:0]	address_08;

always @(posedge clk)   // ¿ØÖÆ¸öÔËËãÄ£¿é³õÊ¼»¯µÈ
	begin
	if (!reset)
		begin
		//coder_first <= 1'b0;
		bit_in	<= 1'b0; bit_in_en <= 1'b0;
		media_en <= 35'b00000_0000000000_0000000000_0000000001;     // ³õÊ¼»¯Ê±¾ÍĞ´ÈëµÚÒ»¸ömedia
		address_04 <= 10'd0; address_06 <= 10'd0; address_08 <= 10'd0;
		state <= state0;
		end
	else 
		begin
		case (velocity)
			2'b01 :  // 0.4 ÂëÂÊ
			begin
			bit_in	<= data_in; bit_in_en <= data_in_en;   // ÊäÈëÊı¾İ
			if(data_in_en)
				begin
				case (state)
					state0 :   //Ç°35¸ö·ûºÅ£¬ĞèÒª°´Ë³Ğò¶ÔmediaĞ´³õÊ¼ĞÅÏ¢
					begin
					if(media_en == 35'b10000_0000000000_0000000000_0000000000)
						begin
						state <= state1;
						media_en <= 35'd0;
						if(count_row == 0)   //×îºóÒ»ĞĞ×îºóÒ»¸ö¾ØĞÅÏ¢£¬¸´Î»romµØÖ·
							begin
							address_04 <= 10'd0;
							end
						else
							begin
							address_04 <= address_04+1'b1;
							end	
						end	
					else
						begin		
						address_04 <= address_04+1'b1;                 // ×´Ì¬µØÖ·ÀÛ¼Ó
						media_en <= media_en << 1;                        //°´Ë³Ğò¸ü¸Ä35¸öÔËËãÄ£¿éµÄmedia_en£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						end											
					end
					state1 :   // ºóÃæÊäÈëÊı¾İ£¬Ñ­»·ÔËËã¼´¿É£¬²»ĞèĞ´¾ØÕó³õÊ¼ĞÅÏ¢
					begin					
					if(count_127 == order)
						begin
						media_en <= 35'b00000_0000000000_0000000000_0000000001; //ÓëµÚ127¸öÊı¾İÊäÈëÍ¬Ê±£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						state <= state0;                                      
						end		
					end
				endcase
				end
			end
			
			2'b10 : // 0.6ÂëÂÊ
			begin
			bit_in	<= data_in; bit_in_en <= data_in_en;   // ÊäÈëÊı¾İ
			if(data_in_en)
				begin
				
				case (state)
					state0 :   //Ç°23¸ö·ûºÅ£¬ĞèÒª°´Ë³Ğò¶ÔmediaĞ´³õÊ¼ĞÅÏ¢
					begin
					if(media_en == 35'b00000_0000000100_0000000000_0000000000)
						begin
						state <= state1;
						media_en <= 35'd0;
						if(count_row == 0)   //×îºóÒ»ĞĞ×îºóÒ»¸ö¾ØĞÅÏ¢£¬¸´Î»romµØÖ·
							begin
							address_06 <= 10'd0;
							end
						else
							begin
							address_06 <= address_06+1'b1;
							end	
						end	
					else
						begin		
						address_06 <= address_06+1'b1;                 // ×´Ì¬µØÖ·ÀÛ¼Ó
						media_en <= media_en << 1;                        //°´Ë³Ğò¸ü¸Ä35¸öÔËËãÄ£¿éµÄmedia_en£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						end											
					end
					state1 :   // ºóÃæÊäÈëÊı¾İ£¬Ñ­»·ÔËËã¼´¿É£¬²»ĞèĞ´¾ØÕó³õÊ¼ĞÅÏ¢
					begin					
					if(count_127 == order)
						begin
						media_en <= 35'b00000_0000000000_0000000000_0000000001; //ÓëµÚ127¸öÊı¾İÊäÈëÍ¬Ê±£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						state <= state0;                                      
						end		
					end
				endcase
				end
			end
						
			2'b11 :
			begin
			bit_in	<= data_in; bit_in_en <= data_in_en;   // ÊäÈëÊı¾İ
			if(data_in_en)
				begin

				case (state)
					state0 :   //Ç°35¸ö·ûºÅ£¬ĞèÒª°´Ë³Ğò¶ÔmediaĞ´³õÊ¼ĞÅÏ¢
					begin
					if(media_en == 35'b00000_000000000_0000000001_0000000000)
						begin
						state <= state1;
						media_en <= 35'd0;
						if(count_row == 0)   //×îºóÒ»ĞĞ×îºóÒ»¸ö¾ØĞÅÏ¢£¬¸´Î»romµØÖ·
							begin
							address_08 <= 10'd0;
							end
						else
							begin
							address_08 <= address_08+1'b1;
							end	
						end	
					else
						begin		
						address_08 <= address_08+1'b1;                 // ×´Ì¬µØÖ·ÀÛ¼Ó
						media_en <= media_en << 1;                        //°´Ë³Ğò¸ü¸Ä35¸öÔËËãÄ£¿éµÄmedia_en£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						end											
					end
					state1 :   // ºóÃæÊäÈëÊı¾İ£¬Ñ­»·ÔËËã¼´¿É£¬²»ĞèĞ´¾ØÕó³õÊ¼ĞÅÏ¢
					begin					
					if(count_127 == order)
						begin
						media_en <= 35'b00000_0000000000_0000000000_0000000001; //ÓëµÚ127¸öÊı¾İÊäÈëÍ¬Ê±£¬Ğ´Èë³õÊ¼ĞÅÏ¢
						state <= state0;                                      
						end		
					end
				endcase
				end
			end		
			default :
				begin
				bit_in	<= data_in; bit_in_en <= data_in_en;   // ÊäÈëÊı¾İ
				if(data_in_en)
					begin
					case (state)
						state0 :   //Ç°35¸ö·ûºÅ£¬ĞèÒª°´Ë³Ğò¶ÔmediaĞ´³õÊ¼ĞÅÏ¢
						begin
						if(media_en == 35'b10000_0000000000_0000000000_0000000000)
							begin
							state <= state1;
							media_en <= 35'd0;
							if(count_row == 0)   //×îºóÒ»ĞĞ×îºóÒ»¸ö¾ØĞÅÏ¢£¬¸´Î»romµØÖ·
								begin
								address_04 <= 9'd0;
								end
							else
								begin
								address_04 <= address_04+1'b1;
								end	
							end	
						else
							begin		
							address_04 <= address_04+1'b1;                 // ×´Ì¬µØÖ·ÀÛ¼Ó
							media_en <= media_en << 1;                        //°´Ë³Ğò¸ü¸Ä35¸öÔËËãÄ£¿éµÄmedia_en£¬Ğ´Èë³õÊ¼ĞÅÏ¢
							end											
						end
						state1 :   // ºóÃæÊäÈëÊı¾İ£¬Ñ­»·ÔËËã¼´¿É£¬²»ĞèĞ´¾ØÕó³õÊ¼ĞÅÏ¢
						begin					
						if(count_127 == order)
							begin
							media_en <= 35'b00000_0000000000_0000000000_0000000001; //ÓëµÚ127¸öÊı¾İÊäÈëÍ¬Ê±£¬Ğ´Èë³õÊ¼ĞÅÏ¢
							state <= state0;                                      
							end		
						end
					endcase
					end
				end
		endcase
		end
	end

reg[126:0] rom_data;

always @(posedge clk)
begin
	case (velocity)
	2'b01 : 	//0.4ÂëÂÊ
		begin					
        rom_data<=rom_data04;
		end
	2'b10 :  	//0.6ÂëÂÊ
		begin					
		rom_data<=rom_data06;
		end
	 2'b11 :	//0.8ÂëÂÊ
		begin					
		rom_data<=rom_data08;
		end	
	default :            // Ä¬ÈÏ0.4ÂëÂÊ
		begin					
		rom_data<=rom_data04;
		end
	endcase	
end



reg[6:0] count;
reg[126:0] wr_data;
reg[125:0] data;
reg  wr_en;

always @(posedge clk)   // ´®²¢×ª»»Êı¾İÎ»£¬´æÈëfifo
	begin
	if(!reset)
		begin
		count<=7'd0;
		data<=126'd0;
		wr_data<=126'd0;
		wr_en<=1'b0;
		end
	else
		begin
		case (velocity)
		  2'b01 : 	//0.4ÂëÂÊ
			begin					
			if(en_media34==1)
				begin
				if(count==126)
					begin
					wr_data<={data[125:0],data_media34};
					wr_en<=1'b1;
					count<=7'd0;
					end
				else
					begin
					data<= {data[124:0],data_media34};
					wr_en<=1'b0;
					count<=count+1'b1;
					end
				end
			else
				begin
				wr_en<=1'b0;
				end		
			end
		  2'b10 :  	//0.6ÂëÂÊ
			begin					
			if(en_media22==1)
				begin
				if(count==126)
					begin
					wr_data<={data[125:0],data_media22};
					wr_en<=1'b1;
					count<=7'd0;
					end
				else
					begin
					data<= {data[124:0],data_media22};
					wr_en<=1'b0;
					count<=count+1'b1;
					end
				end
			else
				begin
				wr_en<=1'b0;
				end	
			end
		  2'b11 :	//0.8ÂëÂÊ
			begin					
			if(en_media10==1)
				begin
				if(count==126)
					begin
					wr_data<={data[125:0],data_media10};
					wr_en<=1'b1;
					count<=7'd0;
					end
				else
					begin
					data<= {data[124:0],data_media10};
					wr_en<=1'b0;
					count<=count+1'b1;
					end
				end
			else
				begin
				wr_en<=1'b0;
				end	
			end	
		default :            // Ä¬ÈÏ0.4ÂëÂÊ
			begin					
			if(en_media34==1)
				begin
				if(count==126)
					begin
					wr_data<={data[125:0],data_media34};
					wr_en<=1'b1;
					count<=7'd0;
					end
				else
					begin
					data<= {data[124:0],data_media34};
					wr_en<=1'b0;
					count<=count+1'b1;
					end
				end
			else
				begin
				wr_en<=1'b0;
				end		
			end		
		endcase
				
	end
end


reg[126:0] data_out;
reg  data_out_en,indication,rd_en;
wire[126:0] fifo_out;

always @(posedge clk)  //¿ØÖÆÊä³ö
	begin
	if(!reset)
		begin
		data_out <= 127'd0;
		data_out_en <= 1'b0;
		indication <= 1'b0;
		end
	else
		begin
		if(data_in_en)
			begin
			case (velocity)
			  2'b01 : 	//0.4ÂëÂÊ
				begin					
				if(count_row == 0) // ×îºóÒ»ĞĞÔËËã
					begin
					case (count_127)  // Êä³öĞ£ÑéÎ»
						7'd2 :	data_out <= data_0;		7'd12 : data_out <= data_10;	7'd22 : data_out <= data_20;	7'd32 : data_out <= data_30;
						7'd3 :	data_out <= data_1;		7'd13 : data_out <= data_11;	7'd23 : data_out <= data_21;	7'd33 : data_out <= data_31;
						7'd4 :	data_out <= data_2;		7'd14 : data_out <= data_12;	7'd24 : data_out <= data_22;	7'd34 : data_out <= data_32;
						7'd5 :	data_out <= data_3;		7'd15 : data_out <= data_13;	7'd25 : data_out <= data_23;	7'd35 : data_out <= data_33;
						7'd6 :	data_out <= data_4;		7'd16 : data_out <= data_14;	7'd26 : data_out <= data_24;	7'd36 : data_out <= data_34;
						7'd7 : data_out <= data_5;		7'd17 : data_out <= data_15;	7'd27 : data_out <= data_25;
						7'd8 : data_out <= data_6;		7'd18 : data_out <= data_16;	7'd28 : data_out <= data_26;
						7'd9 : data_out <= data_7;		7'd19 : data_out <= data_17;	7'd29 : data_out <= data_27;
						7'd10 : data_out <= data_8;	7'd20 : data_out <= data_18;	7'd30 : data_out <= data_28;
						7'd11 : data_out <= data_9;	7'd21 : data_out <= data_19;	7'd31 : data_out <= data_29;
					endcase
					
					if(count_127==2) // Êä³öµÚÒ»¸ö127Ö¸Ê¾ĞÅºÅ
						begin
						indication <= 1'b1;
						end
					else
						begin
						indication <= 1'b0;
						end
						
					if((count_127>=34)&&(count_127<=58))  //·¢³ö¶ÁfifoÖ¸Áî
						begin
						rd_en<=1'b1;						
						end
					else
						begin
						rd_en<=1'b0;
						end	
						
					if((count_127>=36)&&(count_127<=60))  //¶ÁfifoÊä³ö£¬Êä³öÊı¾İÎ»
						begin
						data_out <= fifo_out;						
						end
						
					if((count_127>=2)&&(count_127<=60)) //Ê¹ÄÜĞÅºÅ
						begin
						data_out_en<=1'b1;
						end
					else
						begin
						data_out_en<=1'b0;
						end	
					end
				else
					begin
					indication<= 1'b0;
					data_out_en<=1'b0;
					rd_en<=1'b0;
					end
				end
			  2'b10 :  	//0.6ÂëÂÊ
				begin					
				if(count_row == 0) // ×îºóÒ»ĞĞÔËËã
					begin
					case (count_127)  // Êä³öĞ£ÑéÎ»
						7'd2 :	data_out <= data_0;		7'd12 : data_out <= data_10;	7'd22 : data_out <= data_20;	//32 : data_out <= data_30;
						7'd3 :	data_out <= data_1;		7'd13 : data_out <= data_11;	7'd23 : data_out <= data_21;	//33 : data_out <= data_31;
						7'd4 :	data_out <= data_2;		7'd14 : data_out <= data_12;	7'd24 : data_out <= data_22;	//34 : data_out <= data_32;
						7'd5 :	data_out <= data_3;		7'd15 : data_out <= data_13;	//25 : data_out <= data_23;	35 : data_out <= data_33;
						7'd6 :	data_out <= data_4;		7'd16 : data_out <= data_14;	//26 : data_out <= data_24;	36 : data_out <= data_34;
						7'd7 : data_out <= data_5;		7'd17 : data_out <= data_15;	//27 : data_out <= data_25;
						7'd8 : data_out <= data_6;		7'd18 : data_out <= data_16;	//28 : data_out <= data_26;
						7'd9 : data_out <= data_7;		7'd19 : data_out <= data_17;	//29 : data_out <= data_27;
						7'd10 : data_out <= data_8;	7'd20 : data_out <= data_18;	//30 : data_out <= data_28;
						7'd11 : data_out <= data_9;	7'd21 : data_out <= data_19;	//31 : data_out <= data_29;
					endcase
					
					if(count_127==7'd2) // Êä³öµÚÒ»¸ö127Ö¸Ê¾ĞÅºÅ
						begin
						indication <= 1'b1;
						end
					else
						begin
						indication <= 1'b0;
						end
						
					if((count_127>=7'd23)&&(count_127<=7'd58))  //·¢³ö¶ÁfifoÖ¸Áî
						begin
						rd_en<=1'b1;						
						end
					else
						begin
						rd_en<=1'b0;
						end	
						
					if((count_127>=7'd25)&&(count_127<=7'd60))  //¶ÁfifoÊä³ö£¬Êä³öÊı¾İÎ»
						begin
						data_out <= fifo_out;						
						end
						
					if((count_127>=7'd2)&&(count_127<=7'd60)) //Ê¹ÄÜĞÅºÅ
						begin
						data_out_en<=1'b1;
						end
					else
						begin
						data_out_en<=1'b0;
						end	
					end
				else
					begin
					indication<= 1'b0;
					data_out_en<=1'b0;
					rd_en<=1'b0;
					end
				end
			  2'b11 :	//0.8ÂëÂÊ
				begin					
				if(count_row == 0) // ×îºóÒ»ĞĞÔËËã
					begin
					case (count_127)  // Êä³öĞ£ÑéÎ»
						7'd2 :	data_out <= data_0;		//12 : data_out <= data_10;	22 : data_out <= data_20;	//32 : data_out <= data_30;
						7'd3 :	data_out <= data_1;		//13 : data_out <= data_11;	23 : data_out <= data_21;	//33 : data_out <= data_31;
						7'd4 :	data_out <= data_2;		//14 : data_out <= data_12;	24 : data_out <= data_22;	//34 : data_out <= data_32;
						7'd5 :	data_out <= data_3;		//15 : data_out <= data_13;	//25 : data_out <= data_23;	35 : data_out <= data_33;
						7'd6 :	data_out <= data_4;		//16 : data_out <= data_14;	//26 : data_out <= data_24;	36 : data_out <= data_34;
						7'd7 : data_out <= data_5;		//17 : data_out <= data_15;	//27 : data_out <= data_25;
						7'd8 : data_out <= data_6;		//18 : data_out <= data_16;	//28 : data_out <= data_26;
						7'd9 : data_out <= data_7;		//19 : data_out <= data_17;	//29 : data_out <= data_27;
						7'd10 : data_out <= data_8;	//20 : data_out <= data_18;	//30 : data_out <= data_28;
						//11 : data_out <= data_9;	21 : data_out <= data_19;	//31 : data_out <= data_29;
					endcase
					
					if(count_127==7'd2) // Êä³öµÚÒ»¸ö127Ö¸Ê¾ĞÅºÅ
						begin
						indication <= 1'b1;
						end
					else
						begin
						indication <= 1'b0;
						end
						
					if((count_127>=7'd9)&&(count_127<=7'd58))  //·¢³ö¶ÁfifoÖ¸Áî
						begin
						rd_en<=1'b1;						
						end
					else
						begin
						rd_en<=1'b0;
						end	
						
					if((count_127>=7'd11)&&(count_127<=7'd60))  //¶ÁfifoÊä³ö£¬Êä³öÊı¾İÎ»
						begin
						data_out <= fifo_out;						
						end
						
					if((count_127>=7'd2)&&(count_127<=7'd60)) //Ê¹ÄÜĞÅºÅ
						begin
						data_out_en<=1'b1;
						end
					else
						begin
						data_out_en<=1'b0;
						end	
					end
				else
					begin
					indication<= 1'b0;
					data_out_en<=1'b0;
					rd_en<=1'b0;
					end
				end
			default :            // Ä¬ÈÏ0.4ÂëÂÊ
				begin					
				if(count_row == 0) // ×îºóÒ»ĞĞÔËËã
					begin
					case (count_127)  // Êä³öĞ£ÑéÎ»
						7'd2 :	data_out <= data_0;		7'd12 : data_out <= data_10;	7'd22 : data_out <= data_20;	7'd32 : data_out <= data_30;
						7'd3 :	data_out <= data_1;		7'd13 : data_out <= data_11;	7'd23 : data_out <= data_21;	7'd33 : data_out <= data_31;
						7'd4 :	data_out <= data_2;		7'd14 : data_out <= data_12;	7'd24 : data_out <= data_22;	7'd34 : data_out <= data_32;
						7'd5 :	data_out <= data_3;		7'd15 : data_out <= data_13;	7'd25 : data_out <= data_23;	7'd35 : data_out <= data_33;
						7'd6 :	data_out <= data_4;		7'd16 : data_out <= data_14;	7'd26 : data_out <= data_24;	7'd36 : data_out <= data_34;
						7'd7 : data_out <= data_5;		7'd17 : data_out <= data_15;	7'd27 : data_out <= data_25;
						7'd8 : data_out <= data_6;		7'd18 : data_out <= data_16;	7'd28 : data_out <= data_26;
						7'd9 : data_out <= data_7;		7'd19 : data_out <= data_17;	7'd29 : data_out <= data_27;
						7'd10 : data_out <= data_8;	7'd20 : data_out <= data_18;	7'd30 : data_out <= data_28;
						7'd11 : data_out <= data_9;	7'd21 : data_out <= data_19;	7'd31 : data_out <= data_29;
					endcase
					
					if(count_127==2) // Êä³öµÚÒ»¸ö127Ö¸Ê¾ĞÅºÅ
						begin
						indication <= 1'b1;
						end
					else
						begin
						indication <= 1'b0;
						end
						
					if((count_127>=34)&&(count_127<=58))  //·¢³ö¶ÁfifoÖ¸Áî
						begin
						rd_en<=1'b1;						
						end
					else
						begin
						rd_en<=1'b0;
						end	
						
					if((count_127>=36)&&(count_127<=60))  //¶ÁfifoÊä³ö£¬Êä³öÊı¾İÎ»
						begin
						data_out <= fifo_out;						
						end
						
					if((count_127>=2)&&(count_127<=60)) //Ê¹ÄÜĞÅºÅ
						begin
						data_out_en<=1'b1;
						end
					else
						begin
						data_out_en<=1'b0;
						end	
					end
				else
					begin
					indication<= 1'b0;
					data_out_en<=1'b0;
					rd_en<=1'b0;
					end
				end
			endcase	
			end
		end		
	end
	
wire[126:0] rom_data04; 
wire[126:0] rom_data06;
wire[126:0] rom_data08; 

wire data_media0,data_media1,data_media2,data_media3,data_media4,data_media5,data_media6,data_media7,data_media8,data_media9,
	 data_media10,data_media11,data_media12,data_media13,data_media14,data_media15,data_media16,data_media17,data_media18,data_media19,
	 data_media20,data_media21,data_media22,data_media23,data_media24,data_media25,data_media26,data_media27,data_media28,data_media29,
	 data_media30,data_media31,data_media32,data_media33,data_media34;  // Êı¾İ
wire en_media0,en_media1,en_media2,en_media3,en_media4,en_media5,en_media6,en_media7,en_media8,en_media9,
	 en_media10,en_media11,en_media12,en_media13,en_media14,en_media15,en_media16,en_media17,en_media18,en_media19,
	 en_media20,en_media21,en_media22,en_media23,en_media24,en_media25,en_media26,en_media27,en_media28,en_media29,
	 en_media30,en_media31,en_media32,en_media33,en_media34;  // Á¬½Óbit_en
wire first_media0,first_media1,first_media2,first_media3,first_media4,first_media5,first_media6,first_media7,first_media8,first_media9,
	 first_media10,first_media11,first_media12,first_media13,first_media14,first_media15,first_media16,first_media17,first_media18,first_media19,
	 first_media20,first_media21,first_media22,first_media23,first_media24,first_media25,first_media26,first_media27,first_media28,first_media29,
	 first_media30,first_media31,first_media32,first_media33,first_media34;
wire[126:0] data_0,data_1,data_2,data_3,data_4,data_5,data_6,data_7,data_8,data_9,
	 data_10,data_11,data_12,data_13,data_14,data_15,data_16,data_17,data_18,data_19,
	 data_20,data_21,data_22,data_23,data_24,data_25,data_26,data_27,data_28,data_29,
	 data_30,data_31,data_32,data_33,data_34;	
	
matrix_op     m0( .clk(clk),.reset(reset),.bit_in(bit_in),.bit_in_en(bit_in_en), .media_in(rom_data),.media_in_en(media_en[0]),
	  .coder_first(coder_first),.bit_out(data_media0),.bit_out_en(en_media0), .first_out(first_media0),.data_out(data_0));	
matrix_op     m1( .clk(clk),.reset(reset),.bit_in(data_media0),.bit_in_en(en_media0), .media_in(rom_data),.media_in_en(media_en[1]),
	  .coder_first(first_media0),.bit_out(data_media1),.bit_out_en(en_media1), .first_out(first_media1),.data_out(data_1));	
matrix_op     m2( .clk(clk),.reset(reset),.bit_in(data_media1),.bit_in_en(en_media1), .media_in(rom_data),.media_in_en(media_en[2]),
	  .coder_first(first_media1),.bit_out(data_media2),.bit_out_en(en_media2), .first_out(first_media2),.data_out(data_2) );	
matrix_op     m3( .clk(clk),.reset(reset),.bit_in(data_media2),.bit_in_en(en_media2), .media_in(rom_data),.media_in_en(media_en[3]),
	  .coder_first(first_media2),.bit_out(data_media3),.bit_out_en(en_media3), .first_out(first_media3),.data_out(data_3) );	
matrix_op     m4( .clk(clk),.reset(reset),.bit_in(data_media3),.bit_in_en(en_media3), .media_in(rom_data),.media_in_en(media_en[4]),
	  .coder_first(first_media3),.bit_out(data_media4),.bit_out_en(en_media4), .first_out(first_media4),.data_out(data_4) );	
matrix_op     m5( .clk(clk),.reset(reset),.bit_in(data_media4),.bit_in_en(en_media4), .media_in(rom_data),.media_in_en(media_en[5]),
	  .coder_first(first_media4),.bit_out(data_media5),.bit_out_en(en_media5), .first_out(first_media5),.data_out(data_5) );	
matrix_op     m6( .clk(clk),.reset(reset),.bit_in(data_media5),.bit_in_en(en_media5), .media_in(rom_data),.media_in_en(media_en[6]),
	  .coder_first(first_media5),.bit_out(data_media6),.bit_out_en(en_media6), .first_out(first_media6),.data_out(data_6));	
matrix_op     m7( .clk(clk),.reset(reset),.bit_in(data_media6),.bit_in_en(en_media6), .media_in(rom_data),.media_in_en(media_en[7]),
	  .coder_first(first_media6),.bit_out(data_media7),.bit_out_en(en_media7), .first_out(first_media7),.data_out(data_7) );	
matrix_op     m8( .clk(clk),.reset(reset),.bit_in(data_media7),.bit_in_en(en_media7), .media_in(rom_data),.media_in_en(media_en[8]),
	  .coder_first(first_media7),.bit_out(data_media8),.bit_out_en(en_media8), .first_out(first_media8),.data_out(data_8));	
matrix_op      m9( .clk(clk),.reset(reset),.bit_in(data_media8),.bit_in_en(en_media8), .media_in(rom_data),.media_in_en(media_en[9]),
	  .coder_first(first_media8),.bit_out(data_media9),.bit_out_en(en_media9), .first_out(first_media9),.data_out(data_9));	
matrix_op      m10( .clk(clk),.reset(reset),.bit_in(data_media9),.bit_in_en(en_media9), .media_in(rom_data),.media_in_en(media_en[10]),
  .coder_first(first_media9),.bit_out(data_media10),.bit_out_en(en_media10), .first_out(first_media10),.data_out(data_10) );	
matrix_op      m11( .clk(clk),.reset(reset),.bit_in(data_media10),.bit_in_en(en_media10), .media_in(rom_data),.media_in_en(media_en[11]),
  .coder_first(first_media10),.bit_out(data_media11),.bit_out_en(en_media11), .first_out(first_media11),.data_out(data_11) );	
matrix_op      m12( .clk(clk),.reset(reset),.bit_in(data_media11),.bit_in_en(en_media11), .media_in(rom_data),.media_in_en(media_en[12]),
  .coder_first(first_media11),.bit_out(data_media12),.bit_out_en(en_media12), .first_out(first_media12),.data_out(data_12) );	
matrix_op      m13( .clk(clk),.reset(reset),.bit_in(data_media12),.bit_in_en(en_media12), .media_in(rom_data),.media_in_en(media_en[13]),
  .coder_first(first_media12),.bit_out(data_media13),.bit_out_en(en_media13), .first_out(first_media13),.data_out(data_13) );	
matrix_op      m14( .clk(clk),.reset(reset),.bit_in(data_media13),.bit_in_en(en_media13), .media_in(rom_data),.media_in_en(media_en[14]),
  .coder_first(first_media13),.bit_out(data_media14),.bit_out_en(en_media14), .first_out(first_media14),.data_out(data_14) );	
matrix_op      m15( .clk(clk),.reset(reset),.bit_in(data_media14),.bit_in_en(en_media14), .media_in(rom_data),.media_in_en(media_en[15]),
  .coder_first(first_media14),.bit_out(data_media15),.bit_out_en(en_media15), .first_out(first_media15),.data_out(data_15) );	
matrix_op      m16( .clk(clk),.reset(reset),.bit_in(data_media15),.bit_in_en(en_media15), .media_in(rom_data),.media_in_en(media_en[16]),
  .coder_first(first_media15),.bit_out(data_media16),.bit_out_en(en_media16), .first_out(first_media16),.data_out(data_16) );	
matrix_op      m17( .clk(clk),.reset(reset),.bit_in(data_media16),.bit_in_en(en_media16), .media_in(rom_data),.media_in_en(media_en[17]),
  .coder_first(first_media16),.bit_out(data_media17),.bit_out_en(en_media17), .first_out(first_media17),.data_out(data_17) );	
matrix_op      m18( .clk(clk),.reset(reset),.bit_in(data_media17),.bit_in_en(en_media17), .media_in(rom_data),.media_in_en(media_en[18]),
  .coder_first(first_media17),.bit_out(data_media18),.bit_out_en(en_media18), .first_out(first_media18),.data_out(data_18) );	
matrix_op      m19( .clk(clk),.reset(reset),.bit_in(data_media18),.bit_in_en(en_media18), .media_in(rom_data),.media_in_en(media_en[19]),
  .coder_first(first_media18),.bit_out(data_media19),.bit_out_en(en_media19), .first_out(first_media19),.data_out(data_19) );	
matrix_op      m20( .clk(clk),.reset(reset),.bit_in(data_media19),.bit_in_en(en_media19), .media_in(rom_data),.media_in_en(media_en[20]),
  .coder_first(first_media19),.bit_out(data_media20),.bit_out_en(en_media20), .first_out(first_media20),.data_out(data_20) );	
matrix_op      m21( .clk(clk),.reset(reset),.bit_in(data_media20),.bit_in_en(en_media20), .media_in(rom_data),.media_in_en(media_en[21]),
  .coder_first(first_media20),.bit_out(data_media21),.bit_out_en(en_media21), .first_out(first_media21),.data_out(data_21) );	
matrix_op      m22( .clk(clk),.reset(reset),.bit_in(data_media21),.bit_in_en(en_media21), .media_in(rom_data),.media_in_en(media_en[22]),
  .coder_first(first_media21),.bit_out(data_media22),.bit_out_en(en_media22), .first_out(first_media22),.data_out(data_22));	
matrix_op      m23( .clk(clk),.reset(reset),.bit_in(data_media22),.bit_in_en(en_media22), .media_in(rom_data),.media_in_en(media_en[23]),
  .coder_first(first_media22),.bit_out(data_media23),.bit_out_en(en_media23), .first_out(first_media23),.data_out(data_23));	
matrix_op      m24( .clk(clk),.reset(reset),.bit_in(data_media23),.bit_in_en(en_media23), .media_in(rom_data),.media_in_en(media_en[24]),
  .coder_first(first_media23),.bit_out(data_media24),.bit_out_en(en_media24), .first_out(first_media24),.data_out(data_24));	
matrix_op      m25( .clk(clk),.reset(reset),.bit_in(data_media24),.bit_in_en(en_media24), .media_in(rom_data),.media_in_en(media_en[25]),
  .coder_first(first_media24),.bit_out(data_media25),.bit_out_en(en_media25), .first_out(first_media25),.data_out(data_25));	
matrix_op      m26( .clk(clk),.reset(reset),.bit_in(data_media25),.bit_in_en(en_media25), .media_in(rom_data),.media_in_en(media_en[26]),
  .coder_first(first_media25),.bit_out(data_media26),.bit_out_en(en_media26), .first_out(first_media26),.data_out(data_26) );	
matrix_op      m27( .clk(clk),.reset(reset),.bit_in(data_media26),.bit_in_en(en_media26), .media_in(rom_data),.media_in_en(media_en[27]),
  .coder_first(first_media26),.bit_out(data_media27),.bit_out_en(en_media27), .first_out(first_media27),.data_out(data_27));	
matrix_op      m28( .clk(clk),.reset(reset),.bit_in(data_media27),.bit_in_en(en_media27), .media_in(rom_data),.media_in_en(media_en[28]),
  .coder_first(first_media27),.bit_out(data_media28),.bit_out_en(en_media28), .first_out(first_media28),.data_out(data_28));	
matrix_op      m29( .clk(clk),.reset(reset),.bit_in(data_media28),.bit_in_en(en_media28), .media_in(rom_data),.media_in_en(media_en[29]),
  .coder_first(first_media28),.bit_out(data_media29),.bit_out_en(en_media29), .first_out(first_media29),.data_out(data_29));	
matrix_op      m30( .clk(clk),.reset(reset),.bit_in(data_media29),.bit_in_en(en_media29), .media_in(rom_data),.media_in_en(media_en[30]),
  .coder_first(first_media29),.bit_out(data_media30),.bit_out_en(en_media30), .first_out(first_media30),.data_out(data_30));	
matrix_op      m31( .clk(clk),.reset(reset),.bit_in(data_media30),.bit_in_en(en_media30), .media_in(rom_data),.media_in_en(media_en[31]),
  .coder_first(first_media30),.bit_out(data_media31),.bit_out_en(en_media31), .first_out(first_media31),.data_out(data_31) );	
matrix_op      m32( .clk(clk),.reset(reset),.bit_in(data_media31),.bit_in_en(en_media31), .media_in(rom_data),.media_in_en(media_en[32]),
  .coder_first(first_media31),.bit_out(data_media32),.bit_out_en(en_media32), .first_out(first_media32),.data_out(data_32) );	
matrix_op      m33( .clk(clk),.reset(reset),.bit_in(data_media32),.bit_in_en(en_media32), .media_in(rom_data),.media_in_en(media_en[33]),
  .coder_first(first_media32),.bit_out(data_media33),.bit_out_en(en_media33), .first_out(first_media33),.data_out(data_33) );	
matrix_op      m34( .clk(clk),.reset(reset),.bit_in(data_media33),.bit_in_en(en_media33), .media_in(rom_data),.media_in_en(media_en[34]),
  .coder_first(first_media33),.bit_out(data_media34),.bit_out_en(en_media34), .first_out(first_media34),.data_out(data_34) );	


altsyncram	altsyncram_component_04 (
				.clock0 (clk),
				.address_a (address_04),
				.q_a (rom_data04),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.q_b (),
				.clocken1 (1'b1),
				.clocken0 (1'b1),
				.data_b (1'b1),
				.wren_a (1'b0),
				.data_a ({127{1'b1}}),
				.rden_b (1'b1),
				.address_b (1'b1),
				.wren_b (1'b0),
				.byteena_b (1'b1),
				.addressstall_a (1'b0),
				.byteena_a (1'b1),
				.addressstall_b (1'b0),
				.clock1 (1'b1));
	defparam
		altsyncram_component_04.address_aclr_a = "NONE",
		altsyncram_component_04.init_file = "0.4×ª»»¾Ø.mif",
		altsyncram_component_04.intended_device_family = "Stratix",
		altsyncram_component_04.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component_04.lpm_type = "altsyncram",
		altsyncram_component_04.numwords_a = 840,
		altsyncram_component_04.operation_mode = "ROM",
		altsyncram_component_04.outdata_aclr_a = "NONE",
		altsyncram_component_04.outdata_reg_a = "CLOCK0",
		altsyncram_component_04.widthad_a = 10,
		altsyncram_component_04.width_a = 127,
		altsyncram_component_04.width_byteena_a = 1;
		
altsyncram	altsyncram_component_06 (
				.clock0 (clk),
				.address_a (address_06),
				.q_a (rom_data06),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.q_b (),
				.clocken1 (1'b1),
				.clocken0 (1'b1),
				.data_b (1'b1),
				.wren_a (1'b0),
				.data_a ({127{1'b1}}),
				.rden_b (1'b1),
				.address_b (1'b1),
				.wren_b (1'b0),
				.byteena_b (1'b1),
				.addressstall_a (1'b0),
				.byteena_a (1'b1),
				.addressstall_b (1'b0),
				.clock1 (1'b1));
	defparam
		altsyncram_component_06.address_aclr_a = "NONE",
		altsyncram_component_06.init_file = "0.6×ª»»¾Ø.mif",
		altsyncram_component_06.intended_device_family = "Stratix",
		altsyncram_component_06.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component_06.lpm_type = "altsyncram",
		altsyncram_component_06.numwords_a = 828,
		altsyncram_component_06.operation_mode = "ROM",
		altsyncram_component_06.outdata_aclr_a = "NONE",
		altsyncram_component_06.outdata_reg_a = "CLOCK0",
		altsyncram_component_06.widthad_a = 10,
		altsyncram_component_06.width_a = 127,
		altsyncram_component_06.width_byteena_a = 1;
		
		altsyncram	altsyncram_component_08 (
				.clock0 (clk),
				.address_a (address_08),
				.q_a (rom_data08),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.q_b (),
				.clocken1 (1'b1),
				.clocken0 (1'b1),
				.data_b (1'b1),
				.wren_a (1'b0),
				.data_a ({127{1'b1}}),
				.rden_b (1'b1),
				.address_b (1'b1),
				.wren_b (1'b0),
				.byteena_b (1'b1),
				.addressstall_a (1'b0),
				.byteena_a (1'b1),
				.addressstall_b (1'b0),
				.clock1 (1'b1));
	defparam
		altsyncram_component_08.address_aclr_a = "NONE",
		altsyncram_component_08.init_file = "0.8×ª»»¾Ø.mif",
		altsyncram_component_08.intended_device_family = "Stratix",
		altsyncram_component_08.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component_08.lpm_type = "altsyncram",
		altsyncram_component_08.numwords_a = 528,
		altsyncram_component_08.operation_mode = "ROM",
		altsyncram_component_08.outdata_aclr_a = "NONE",
		altsyncram_component_08.outdata_reg_a = "CLOCK0",
		altsyncram_component_08.widthad_a = 10,
		altsyncram_component_08.width_a = 127,
		altsyncram_component_08.width_byteena_a = 1;
		
scfifo	scfifo_component (
				.rdreq (rd_en),
				.clock (clk),
				.wrreq (wr_en),
				.data (wr_data),
				.q (fifo_out)
				// synopsys translate_off
				,
				.usedw (),
				.almost_empty (),
				.sclr (),
				.almost_full (),
				.aclr (),
				.empty (),
				.full ()
				// synopsys translate_on
				);
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.intended_device_family = "Stratix",
		scfifo_component.lpm_numwords = 64,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = 127,
		scfifo_component.lpm_widthu = 6,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";


endmodule