module gioco(
	i_ani_stb,														// clock dei pixel
	i_clk,															// clock
	i_rst,															// reset
	i_animate,														// alto quando vengono disegnati i pixel attivi (pixel dello schermo)
	i_dx, 															// tasto destro
	i_sx,																// tasto sinistro
	i_start,															// tasto di start
	o_x1_pal, o_x2_pal,											// lati della palla
	o_y1_pal, o_y2_pal,
	o_x1_nav, o_x2_nav,											// lati della navicella
	o_y1_nav, o_y2_nav,
	bri1,bri2,bri3,bri4,bri5,bri6,bri7,bri8,bri9,bri10,// permettono di capire quali mattoni visualizzare e quali no
	ok, ko,															// permettono di capire se la partita è stata vinta o persa
	ff_life															// numero di vite
);

input i_ani_stb, i_clk, i_rst, i_animate, i_dx, i_sx, i_start;

output [9:0] o_x1_pal, o_x2_pal, o_y1_pal, o_y2_pal, o_x1_nav, o_x2_nav, o_y1_nav, o_y2_nav;
output reg bri1,bri2,bri3,bri4,bri5,bri6,bri7,bri8,bri9,bri10;
output reg ok,ko;												
output [1:0] ff_life;

// il flipflop restituisce informazioni riguardanti quali e quanti mattoni sono attivi, le posizioni della palla e della navicella,
// le direzioni della palla, quante volte sono stati colpiti i mattoni
wire ff_bri1, ff_bri2, ff_bri3, ff_bri4,ff_bri5, ff_bri6, ff_bri7, ff_bri8,ff_bri9, ff_bri10;
wire [9:0] ff_x_nav,ff_y_nav,ff_x_pal,ff_y_pal;	
wire ff_x_dirpal,ff_y_dirpal;							
wire [3:0] ff_brick;
wire [1:0] ff_red1,ff_red2,ff_red3,ff_red4;
wire [1:0] ff_blue5,ff_blue6,ff_blue7;

parameter H_SIZE_BRI = 10'd 32;					// metà larghezza brick
parameter L_SIZE_BRI = 10'd 10; 					// metà altezza brick
parameter H_SIZE_NAV = 10'd 32; 					// metà della larghezza della nave
parameter L_SIZE_NAV = 10'd 3;  					// metà dell'altezza della nave
parameter IX_NAV = 10'd 320;						// coordinata x iniziale del centro della navicella
parameter IY_NAV = 10'd 470;						// coordinata y iniziale del centro della navicella
parameter D_WIDTH = 10'd 640; 				 	// larghezza schermo
parameter D_HEIGHT = 10'd 480;					// altezza schermo
parameter H_SIZE_PAL = 10'd 2;					// metà della larghezza della palla
parameter IX_PAL = 10'd 320;						// coordinata x iniziale del centro della palla
parameter IY_PAL = 10'd 460;						// coordinata y iniziale del centro della palla
parameter VITE = 2'd 3;								// numero di vite
parameter BLOCCHI = 4'd 10;						// numero di mattoni
parameter ROSSO = 2'd 3;							// numero di volte che devono essere colpiti i mattoni rossi per venire eliminati
parameter BLU = 2'd 2;								// numero di volte che devono essere colpiti i mattoni blu per venire eliminati

parameter wait1=4'b 0000;							// codifica degli stati
parameter s0=4'b 0001;
parameter val=4'b 0010;
parameter win=4'b 0100;
parameter go=4'b 1000;

reg [3:0] snext,sreg;								
reg[9:0] x_nav;										// coordinata x del centro della navicella
reg[9:0] y_nav;										//	coordinata y del centro della navicella
reg[9:0] x_pal;										// coordinata x del centro della palla
reg[9:0] y_pal;										// coordinata y del centro della palla
reg x_dir_pal;											// se vale 1 palla a dx, vale 0 palla a sx
reg y_dir_pal;											// se vale 1 la palla va in basso, se vale 0 la palla va in alto
reg [1:0] life;										
reg [3:0] brick;
reg [1:0] red1,red2,red3,red4;
reg [1:0] blue5,blue6,blue7;
 
assign o_x1_nav = x_nav - H_SIZE_NAV;  //coordinata x del lato sx della navicella 
assign o_x2_nav = x_nav + H_SIZE_NAV;  //coordinata x del lato dx della navicella 
assign o_y1_nav = y_nav -L_SIZE_NAV; 	//coordinata y del lato alto della navicella 
assign o_y2_nav = y_nav + L_SIZE_NAV;  //coordinata y del lato basso della navicella 
assign o_x1_pal = x_pal - H_SIZE_PAL;	//coordinata x del lato sx della palla
assign o_x2_pal = x_pal + H_SIZE_PAL;	//coordinata x del lato dx della palla
assign o_y1_pal = y_pal -H_SIZE_PAL;	//coordinata y del lato alto della palla
assign o_y2_pal = y_pal + H_SIZE_PAL;	//coordinata y del lato basso della palla

flipflop ff(									// chiamata al flipflop
	.clk(i_clk),						
	.rst(i_rst),
	.i_xdirpal(x_dir_pal),			
	.i_ydirpal(y_dir_pal),
	.i_xnav(x_nav),
	.i_ynav(y_nav),
	.i_xpal(x_pal),
	.i_ypal(y_pal),
	.i_bri1(bri1),
	.i_bri2(bri2),
	.i_bri3(bri3),
	.i_bri4(bri4),
	.i_bri5(bri5),
	.i_bri6(bri6),
	.i_bri7(bri7),
	.i_bri8(bri8),
	.i_bri9(bri9),
	.i_bri10(bri10),
	.i_life(life),
	.i_brick(brick),
	.i_red1(red1),
	.i_red2(red2),
	.i_red3(red3),
	.i_red4(red4),
	.i_blue5(blue5),
	.i_blue6(blue6),
	.i_blue7(blue7),
	.o_xdirpal(ff_x_dirpal),		// le uscite del flipflop si collegano ai wire creati appositamente
	.o_ydirpal(ff_y_dirpal),
	.o_xnav(ff_x_nav),
	.o_ynav(ff_y_nav),
	.o_xpal(ff_x_pal),
	.o_ypal(ff_y_pal),
	.o_bri1(ff_bri1),
	.o_bri2(ff_bri2),
	.o_bri3(ff_bri3),
	.o_bri4(ff_bri4),
	.o_bri5(ff_bri5),
	.o_bri6(ff_bri6),
	.o_bri7(ff_bri7),
	.o_bri8(ff_bri8),
	.o_bri9(ff_bri9),
	.o_bri10(ff_bri10),
	.o_life(ff_life),
	.o_brick(ff_brick),
	.o_red1(ff_red1),
	.o_red2(ff_red2),
	.o_red3(ff_red3),
	.o_red4(ff_red4),
	.o_blue5(ff_blue5),
	.o_blue6(ff_blue6),
	.o_blue7(ff_blue7)
);

always@(posedge i_clk)				// blocco always per il cambio di stato sul fronte positivo del clock
		if(i_rst)						// reset sincrono
			sreg<=wait1;
		else sreg<=snext;
		
always@(*)								// blocco always per la transizione degli stati
		case(sreg)
			wait1:if(!i_start) snext=s0;							// wait1 è lo stato iniziale di gioco
					else snext=wait1;
								
			s0:   if(i_animate&&i_ani_stb) snext=val; 		// stato di conservazione dei dati	
					else snext=s0;
			val:															// stato di valutazione dei vari parametri
				 if(!ff_life)
					snext=go;
				 else if(!ff_brick)
					snext=win;
				 else if(!(i_animate&&i_ani_stb))
						snext=s0;
				 else snext = val;
			win: if(!i_start) snext=wait1;						// stato a cui si accede nel caso di vittoria
				  else snext=win;
			go:  if(!i_start) snext=wait1;						// stato a cui si accede nel caso di sconfitta
				  else snext=go;
		endcase
	
always@(*)								// blocco always che fornisce le uscite della macchina a stati

	begin
		
		x_dir_pal=0;					// tutte le variabili vengono inizializzate
		y_dir_pal=0;
		x_nav=IX_NAV;
		y_nav=IY_NAV;
		x_pal=IX_PAL;
		y_pal=IY_PAL;
		bri1=1;
		bri2=1;
		bri3=1;
		bri4=1;
		bri5=1;
		bri6=1;
		bri7=1;
		bri8=1;
		bri9=1;
		bri10=1;
		life=VITE;
		brick=BLOCCHI;
		ok=0;
		ko=0;
		red1=ROSSO;
		red2=ROSSO;
		red3=ROSSO;
		red4=ROSSO;
		blue5=BLU;
		blue6=BLU;
		blue7=BLU;
		
		case(sreg)
			
			wait1:				
				begin
					// condizioni iniziali
					x_dir_pal=0;		
					y_dir_pal=0;
					x_nav=IX_NAV;
					y_nav=IY_NAV;
					x_pal=IX_PAL;
					y_pal=IY_PAL;
				   bri1=1;
					bri2=1;
					bri3=1;
					bri4=1;
					bri5=1;
					bri6=1;
					bri7=1;
					bri8=1;
					bri9=1;
					bri10=1;
					life=VITE;
					brick=BLOCCHI;
					red1=ROSSO;
					red2=ROSSO;
					red3=ROSSO;
					red4=ROSSO;
					blue5=BLU;
					blue6=BLU;
					blue7=BLU;
				
				end
		val: 
			begin
				// le varabili vengono sovrascritte
				x_dir_pal=ff_x_dirpal;						
				y_dir_pal=ff_y_dirpal;
				x_nav=ff_x_nav;
				y_nav=ff_y_nav;
				x_pal=ff_x_pal;
				y_pal=ff_y_pal;
				bri1=ff_bri1;
				bri2=ff_bri2;
				bri3=ff_bri3;
				bri4=ff_bri4;
				bri5=ff_bri5;
				bri6=ff_bri6;
				bri7=ff_bri7;
				bri8=ff_bri8;
				bri9=ff_bri9;
				bri10=ff_bri10;
				life=ff_life;
				brick=ff_brick;
				red1=ff_red1;
				red2=ff_red2;
				red3=ff_red3;
				red4=ff_red4;
				blue5=ff_blue5;
				blue6=ff_blue6;
				blue7=ff_blue7;

				// movimento della palla
				x_pal = (x_dir_pal) ? x_pal + 10'd 2 : x_pal - 10'd 2;  		
				y_pal = (y_dir_pal) ? y_pal + 10'd 2 : y_pal - 10'd 2;

				// movimento della navicella
				if (i_sx==1 && i_dx==0)										// se viene premuto il tasto destro
					begin															// NB: i tasti sono attivi bassi
					x_nav =x_nav+10'd 3;										// la navicella si muove verso destra
						if (x_nav >= (D_WIDTH-H_SIZE_NAV-12'd 1))		// se la navicella è al margine dx dello schermo
							x_nav = (D_WIDTH-H_SIZE_NAV-10'd 1);		//	allora rimane dove è
					end
				
				else if(i_dx==1 && i_sx ==0)								// se viene premuto il tasto sinistro
					begin
					x_nav = x_nav - 10'd 3;									// la navicella si muove verso sinistra
						if (x_nav <= H_SIZE_NAV+12'd 1)					// se la navicella è al margine sx dello schermo
							x_nav = H_SIZE_NAV + 10'd 1;					// allora rimane dove è
					end
						else 
							x_nav=x_nav;										// nel caso in cui non viene premuto nessun tasto
							

				if((y_pal <= 73)&&(y_pal >= 71))
				begin
					if((x_pal >= 140)&&(x_pal <=202)&&bri1) //se la palla colpisce brick1 da sotto
						begin
							y_dir_pal =1; //la palla va verso il basso
							red1=red1-2'd 1;
							if(!red1)
								begin
									brick = brick -4'd 1;
									bri1= 1'd 0;
								end
						end
			
					if((x_pal >= 232)&&(x_pal <=296)&&bri2) //se la palla colpisce brick2 da sotto
						begin
							y_dir_pal =1; //la palla va verso il basso
							red2=red2-2'd 1;
							if(!red2)
								begin
									brick = brick -4'd 1;	
									bri2= 1'd 0;
								end
						end
			
				if((x_pal >=346)&&(x_pal <=410)&&bri3) //se la palla colpisce brick3 da sotto
					begin
						y_dir_pal =1; //la palla va verso il basso
						red3=red3-2'd 1;
						if(!red3)
							begin
								brick = brick -4'd 1;
								bri3= 1'd 0;
							end
					end
			
				if((x_pal >= 440)&&(x_pal <=504)&&bri4) //se la palla colpisce brick4 da sotto
					begin
						y_dir_pal =1; //la palla va verso il basso
						red4=red4-2'd 1;
						if(!red4)
							begin
								brick = brick -4'd 1;
								bri4=1'd 0;
							end
					end
			end
	
	if((y_pal <= 123)&&(y_pal >= 121))
			begin
			if((x_pal >= 184)&&(x_pal <=248)&&bri5) //se la palla colpisce brick5 da sotto
					begin
					y_dir_pal =1; //la palla va verso il basso
					blue5=blue5-2'd 1;
					if(!blue5)
					begin
						brick = brick -4'd 1;	
						bri5= 1'd 0;
					end
					end
		
				if((x_pal >= 288)&&(x_pal <=352)&&bri6) //se la palla colpisce brick6 da sotto
					begin
					y_dir_pal =1; //la palla va verso il basso
					blue6=blue6-2'd 1;
					if(!blue6)
						begin	
							brick = brick -4'd 1;	
							bri6=1'd 0;
						end
					end	
			
				if((x_pal >= 392)&&(x_pal <=456)&&bri7) //se la palla colpisce brick7 da sotto
					begin
					y_dir_pal =1; //la palla va verso il basso
					blue7=blue7-2'd 1;
					if(!blue7)
					begin
					brick = brick -4'd 1;	
					bri7= 1'd 0;
					end
					end
			end
		if((y_pal <= 173)&&(y_pal >= 171))
		begin 	if((x_pal >= 232)&&(x_pal <=296)&&bri8) //se la palla colpisce brick8 da sotto
					begin
					y_dir_pal =1; //la palla va verso il basso
					bri8= 1'd 0;
				brick = brick -4'd 1;	
					end
			
				if((x_pal >= 346)&&(x_pal <=410)&&bri9) //se la palla colpisce brick9 da sotto
					begin
					y_dir_pal =1; //la palla va verso il basso
					bri9= 1'd 0;
				brick = brick -4'd 1;	
					end
			end
			if((y_pal <= 203)&&(y_pal >= 201)&&bri10)
			begin
			if((x_pal >= 288)&&(x_pal <=352)) //se la palla colpisce brick10 da sotto
					begin
					y_dir_pal =1; //la palla va verso il basso
					bri10= 1'd 0;	
					brick = brick -4'd 1;
					end		
			
			end
			if((y_pal<=70)&&(y_pal>=50))
			begin
			if((x_pal<=205)&&(x_pal>=203)&&bri1)
					//se la palla colpisce brick1 da destra
					begin
						x_dir_pal=1;	//la palla va a dx
						red1=red1-2'd 1;
						if(!red1)
						begin
						bri1=1'd 0;	
						brick = brick -4'd 1;
						end
					end
			if((x_pal<=205)&&(x_pal>=203)&&bri2)
					//se la palla colpisce brick2 da destra
					begin
						x_dir_pal=1;	//la palla va a dx
						red2=red2-2'd 1;
						if(!red2)
						begin
						bri2=1'd 0;
					brick = brick -4'd 1;	
					end
					end
			if((x_pal<=413)&&(x_pal>=411)&&bri3)
						//se la palla colpisce brick3 da destra
						begin
							x_dir_pal=1;	//la palla va a dx
						red3=red3-2'd 1;
					if(!red3)	begin	bri3=1'd 0;	
							brick = brick -4'd 1;
						end
						end
			if((x_pal<=507)&&(x_pal>=505)&&bri4)
						//se la palla colpisce brick4 da destra
						begin
							x_dir_pal=1;	//la palla va a dx
							red4=red4-2'd 1;
							if(!red4)
							begin
							bri4=1'd 0;	
							brick = brick -4'd 1;
							end
						end
if((x_pal>=135)&&(x_pal<=137)&&bri1)
					//se la palla colpisce brick1 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							red1=red1-2'd 1;
							if(!red1)
							begin
							bri1=1'd 0;	
							brick = brick -4'd 1;
							end
							end
			if((x_pal>=229)&&(x_pal<=231)&&bri2)
					//se la palla colpisce brick2 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							red2=red2-2'd 1;
							if(!red2)
							begin
							bri2=1'd 0;	
							brick = brick -4'd 1;
							end
						end
			if((x_pal>=343)&&(x_pal<=345)&&bri3)
					//se la palla colpisce brick3 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							red3=red3-2'd 1;
							if(!red3)
							begin
							bri3=1'd 0;	
							brick = brick -4'd 1;
							end
						end
			if((x_pal>=437)&&(x_pal<=439)&&bri4)
					//se la palla colpisce brick4 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							red4=red4-2'd 1;
							if(!red4)
							begin
							bri4=1'd 0;	
							brick = brick -4'd 1;
							end
						end
				end
	if((y_pal<=120)&&(y_pal>=100))	
		begin
		if((x_pal<=251)&&(x_pal>=249)&&bri5)
						//se la palla colpisce brick5 da destra
						begin
							x_dir_pal=1;	//la palla va a dx
							blue5=blue5-2'd 1;
							if(!blue5)
							begin 
							bri5=1'd 0;	
							brick = brick -4'd 1;
							end
							end
			if((x_pal<=355)&&(x_pal>=353)&&bri6)	//se la palla colpisce brick6 da destra
						begin
							x_dir_pal=1;	//la palla va a dx
							blue6=blue6-2'd 1;
							if(!blue6)
							begin
							bri6=1'd 0;	
							brick = brick -4'd 1;
							end
					end
			if((x_pal<=459)&&(x_pal>=457)&&bri7)	//se la palla colpisce brick7 da destra
						begin
							x_dir_pal=1;	//la palla va a dx
							blue7=blue7-2'd 1;
							if(!blue7)
							begin
							bri7=1'd 0;	
							brick = brick -4'd 1;
							end
						end
	if((x_pal>=181)&&(x_pal<=183)&&bri5)
					//se la palla colpisce brick5 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							blue5=blue5-2'd 1;
							if(!blue5)
							begin
							bri5=1'd 0;	
							brick = brick -4'd 1;
							end
						end
			if((x_pal>=285)&&(x_pal<=287)&&bri6)
					//se la palla colpisce brick6 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							blue6=blue6-2'd 1;
							if(!blue6)
							begin
							bri6=1'd 0;	
							brick = brick -4'd 1;
							end
						end	
			if((x_pal>=389)&&(x_pal<=391)&&bri7)
					//se la palla colpisce brick7 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							blue7=blue7-2'd 1;
							if(!blue7)
							begin
							bri7=1'd 0;				
							brick = brick -4'd 1;
							end
						end	
			
	end
			if((y_pal<=170)&&(y_pal>=150))
			begin
			if((x_pal<=299)&&(x_pal>=297)&&bri8)
						//se la palla colpisce brick8 da destra
						begin
							x_dir_pal=1;	//la palla va a dx
							bri8=1'd 0;	
							brick = brick -4'd 1;
						end	
			if((x_pal<=349)&&(x_pal>=347)&&bri9)	//se la palla colpisce brick9 da destra
						begin
							x_dir_pal=1;	//la palla va a dx
							bri9=1'd 0;	
							brick = brick -4'd 1;
						end
if((x_pal>=229)&&(x_pal<=231)&&bri8)	//se la palla colpisce brick8 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							bri8=1'd 0;	
							brick = brick -4'd 1;
						end
			if((x_pal>=343)&&(x_pal<=345)&&bri9)	//se la palla colpisce brick9 da sinistra
						begin
							x_dir_pal=0;	//la palla va a sx
							bri9=1'd 0;	
							brick = brick -4'd 1;
						end	
	end
			
					if((y_pal<=220)&&(y_pal>=200)&&bri10)	//se la palla colpisce brick10 da destra
				begin	
				if((x_pal<=355)&&(x_pal>=353))
				begin
							x_dir_pal=1;	//la palla va a dx
							bri10=1'd 0;	
							brick = brick -4'd 1;
						end			
			if((x_pal>=285)&&(x_pal<=287))//se la palla colpisce brick10 da sinistra
			begin
							x_dir_pal=0;	//la palla va a sx
							bri10=1'd 0;
							brick = brick -4'd 1;	
						end	
			end	
			
					
						
			if((y_pal>=47)&&(y_pal<=49))
		begin	
			if((x_pal >= 138)&&(x_pal <=202)&&bri1) //se la palla colpisce brick1 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						red1=red1-2'd 1;
						if(!red1)
						begin
						bri1 = 1'd 0; 
						brick = brick -4'd 1;
						end
						end
		
				if((x_pal >= 232)&&(x_pal <=296)&&bri2) //se la palla colpisce brick2 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						red2=red2-2'd 1;
						if(!red2)
						begin
						bri2 =  1'd 0; 
						brick = brick -4'd 1;
						end
					end
			
				if((x_pal >= 346)&&(x_pal <=410)&&bri3) //se la palla colpisce brick3 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						red3=red3-2'd 1;
						if(!red3)
						begin
						bri3 =  1'd 0;
						brick = brick -4'd 1;	
						end
					end
				if((x_pal >= 440)&&(x_pal <=504)&&bri4) //se la palla colpisce brick4 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						red4=red4-2'd 1;
						if(!red4)
						begin
						bri4 =  1'd 0;
						brick = brick -4'd 1;	
						end
					end	
	end	
		if((y_pal>=97)&&(y_pal<=99))
			begin
			if((x_pal >= 184)&&(x_pal <=248)&&bri5) //se la palla colpisce brick5 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						blue5=blue5-2'd 1;
						if(!blue5)
						begin
						bri5 =  1'd 0;
						brick = brick -4'd 1;	
						end
					end	
			
				if((x_pal >= 288)&&(x_pal <=352)&&bri6) //se la palla colpisce brick6 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						blue6=blue6-2'd 1;
						if(!blue6)
						begin
						bri6 =  1'd 0; 
						brick = brick -4'd 1;
						end
					end	
		
				if((x_pal >= 392)&&(x_pal <=456)&&bri7) //se la palla colpisce brick7 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						blue7=blue7-2'd 1;
						if(!blue7)
						begin
						bri7 =  1'd 0; 
						brick = brick -4'd 1;
						end
					end
			end
			if((y_pal>=147)&&(y_pal<=149))
		begin 
			if((x_pal >= 232)&&(x_pal <=296)&&bri8) //se la palla colpisce brick8 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						bri8 =  1'd 0;
						brick = brick -4'd 1;	
					end
			
				if((x_pal >=346)&&(x_pal <=410)&&bri9) //se la palla colpisce brick9 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						bri9 =  1'd 0;
						brick = brick -4'd 1;	
					end	
			end
			if((y_pal>=197)&&(y_pal<=199))
				if((x_pal >= 288)&&(x_pal <=352)&&bri10) //se la palla colpisce brick10 da sopra
					begin
						y_dir_pal = 0; //la palla va verso l'alto
						bri10 =  1'd 0;
						brick = brick -4'd 1;	
					end

			if(x_pal <= H_SIZE_PAL+1)					//Se la palla è al margine sx dello schermo
				x_dir_pal=1;							//Si sposta a dx
			if(x_pal >= (D_WIDTH-H_SIZE_PAL-1))			//se la palla è al margine dx dello schermo
				x_dir_pal = 0;							//si sposta a sx
			if (y_pal <= H_SIZE_PAL + 1)		//se y è al margine in alto dello schermo
				y_dir_pal = 1;				//vai verso il basso
			if (y_pal>=463)								
				if ((x_pal >= x_nav-H_SIZE_NAV)&&(x_pal <= x_nav + H_SIZE_NAV))	//se la navicella colpisce la palla
					y_dir_pal = 0;							//essa rimbalza
				else 
					begin								
						life=life-2'b01;
						x_pal = IX_PAL;
						y_pal = IY_PAL;
						x_nav = IX_NAV;
					end
					
		end
	
		s0:
			begin
				x_dir_pal=ff_x_dirpal;						//le varie variabili vengono sovrascritte
				y_dir_pal=ff_y_dirpal;
				x_nav=ff_x_nav;
				y_nav=ff_y_nav;
				x_pal=ff_x_pal;
				y_pal=ff_y_pal;
				bri1=ff_bri1;
				bri2=ff_bri2;
				bri3=ff_bri3;
				bri4=ff_bri4;
				bri5=ff_bri5;
				bri6=ff_bri6;
				bri7=ff_bri7;
				bri8=ff_bri8;
				bri9=ff_bri9;
				bri10=ff_bri10;
				life=ff_life;
				brick=ff_brick;
				red1=ff_red1;
				red2=ff_red2;
				red3=ff_red3;
				red4=ff_red4;
				blue5=ff_blue5;
				blue6=ff_blue6;
				blue7=ff_blue7;
			end
		
		win:begin
					ok=1;
			 end
			
		go:begin
					ko=1;
			end
						
	   default:
			begin
				x_dir_pal=0;
				y_dir_pal=0;
				x_nav=IX_NAV;
				y_nav=IY_NAV;
				x_pal=IX_PAL;
				y_pal=IY_PAL;
				bri1=1;
				bri2=1;
				bri3=1;
				bri4=1;
				bri5=1;
				bri6=1;
				bri7=1;
				bri8=1;
				bri9=1;
				bri10=1;
				life=VITE;
				brick=BLOCCHI;
				ok=0;
				ko=0;
				red1=ROSSO;
				red2=ROSSO;
				red3=ROSSO;
				red4=ROSSO;
				blue5=BLU;
				blue6=BLU;
				blue7=BLU;
			end
			
		endcase
	
end			
	
endmodule
