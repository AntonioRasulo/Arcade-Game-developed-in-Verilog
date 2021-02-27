module Arkanoid(
	input CLK,						// clock della scheda
	input RST_BTN,					// bottone di reset
	input DX,						// bottone dx, la navicella va a destra
	input SX,						// bottone sx, la navicella va a sinistra
	input start,					// pulsante di start
	output VGA_HS_O,				// sync orizzontale
	output VGA_VS_O,				// sync verticale
	output reg VGA_RED,			// VGA_R[3] per il monitor VGA
	output reg VGA_GREEN,		// VGA_G[3] per il monitor VGA
	output reg VGA_BLUE,			// VGA_B[3] per il monitor VGA
	output reg RED,				// VGA_R[2] per il monitor VGA	
	output reg GREEN,				// VGA_G[2] per il monitor VGA
	output reg BLUE,				// VGA_B[2] per il monitor VGA
	output reg [6:0] HEX0		// uscite per il display a sette segmenti
);
	
	wire rst = ~RST_BTN;			// i KEY della scheda sono attivi bassi
	wire [9:0] x;					// posizione x del pixel
	wire [8:0] y;					// posizione y del pixel
	wire animate;					// alto per un impulso quando vengono disegnati i pixel attivi (pixel dello schermo)
	
	//generazione clock a 25 MHz per i pixel
	reg [15:0] cnt = 0;
	reg pix_stb = 0;
	always @(posedge CLK)
		{pix_stb, cnt} <= cnt + 16'h8000;
	
	vga640x480 display(			// chiamata al modulo per l'interfacciamento con il monitor 640x480
		.i_clk(CLK),
		.i_pix_stb(pix_stb),
		.i_rst(rst),
		.o_hs(VGA_HS_O),
		.o_vs(VGA_VS_O),
		.o_x(x),
		.o_y(y),
		.o_animate(animate)
	);
	
	 wire ok,ko;							// permettono di capire se la partita è stata vinta o se è stata persa
	 wire navicella;						// utile per disegnare la navicella
	 wire [9:0] nav_x1,nav_x2;			// lati laterali della navicella
	 wire [9:0] nav_y1,nav_y2;			// lati sopra e sotto navicella
	 wire palla;							// utile per disegnare la palla
	 wire [9:0] pal_x1,pal_x2;			// lati laterali della palla
	 wire [9:0] pal_y1,pal_y2;			// lati sopra e sotto della palla
	 wire  bri1;							// questi 10 wire dicono quali brick visualizzare e quali no
	 wire  bri2;
	 wire  bri3;		
	 wire  bri4;		
	 wire  bri5;		
	 wire  bri6;	
	 wire  bri7;	
	 wire  bri8; 
	 wire  bri9;	
	 wire  bri10; 
	 wire brick1;							// questi 10 wire vengono usati per disegnare i vari mattoni
	 wire brick2;
	 wire brick3;
	 wire brick4;
	 wire brick5;
	 wire brick6;
	 wire brick7;
	 wire brick8;
	 wire brick9;
	 wire brick10;
	 reg B20,B21,B22,B23,B24,B25,B26,B27,B28,B29,B30,B31;			//vengono usati per la grafica di partita persa o vinta
	 wire [1:0] lfdisplay;				// fornisce il numero di vite, utile per visualizare sul display a sette segmenti

	gioco np(					// chiamata al modulo della matematica del gioco
		.i_clk(pix_stb),
		.i_ani_stb(pix_stb),
		.i_rst(rst),
		.i_animate(animate),
		.i_dx(DX),
		.i_sx(SX),
		.i_start(start),
		.o_x1_nav(nav_x1),
		.o_x2_nav(nav_x2),
		.o_y1_nav(nav_y1),
		.o_y2_nav(nav_y2),
		.o_x1_pal(pal_x1),
		.o_x2_pal(pal_x2),
		.o_y1_pal(pal_y1),
		.o_y2_pal(pal_y2),
		.bri1(bri1),
		.bri2(bri2),
		.bri3(bri3),
		.bri4(bri4),
		.bri5(bri5),
		.bri6(bri6),
		.bri7(bri7),
		.bri8(bri8),
		.bri9(bri9),
		.bri10(bri10),
		.ok(ok),
		.ko(ko),
		.ff_life(lfdisplay)
	);
	
	always@(*)								// visualizzazione delle vite sul display a sette segmenti
		case(lfdisplay)			
			1: begin
					HEX0[0]=1'b1;HEX0[1]=1'b0;HEX0[2]=1'b0;HEX0[3]=1'b1;HEX0[4]=1'b1;HEX0[5]=1'b1;HEX0[6]=1'b1;		
				end	
			2: begin
					HEX0[0]=1'b0;HEX0[1]=1'b0;HEX0[2]=1'b1;HEX0[3]=1'b0;HEX0[4]=1'b0;HEX0[5]=1'b1;;HEX0[6]=1'b0;		
				end
			3: begin
					HEX0[0]=1'b0;HEX0[1]=1'b0;HEX0[2]=1'b0;HEX0[3]=1'b0;HEX0[4]=1'b1;HEX0[5]=1'b1;;HEX0[6]=1'b0;
				end
			0: begin
					HEX0[0]=1'b0;HEX0[1]=1'b0;HEX0[2]=1'b0;HEX0[3]=1'b0;HEX0[4]=1'b0;HEX0[5]=1'b0;;HEX0[6]=1'b1;
				end	
			default:
				begin
					HEX0[0]=1'b0;HEX0[1]=1'b0;HEX0[2]=1'b0;HEX0[3]=1'b0;HEX0[4]=1'b0;HEX0[5]=1'b0;;HEX0[6]=1'b0;		//tutti accesi
				end
		endcase
	
	assign navicella =((x > nav_x1) & (y > nav_y1) &						// la navicella e la palla vengono disegnati
        (x < nav_x2) & (y < nav_y2)) ? 1'b1 : 1'b0;						// se le coordinate x ed y sono comprese fra 
	assign palla =((x > pal_x1) & (y > pal_y1) &								// loro lati
        (x < pal_x2) & (y < pal_y2)) ? 1'b1 : 1'b0;
	assign brick1 =bri1 ?(((x > 138) & (y > 50) &							// i mattoni vengono disegnati se le coordinate x ed y
        (x < 202) & (y < 70)) ? 1'b1 : 1'b0):1'b0;							// sono comprese fra i loro lati, nel caso in cui
	assign brick2 =bri2 ?(((x > 232) & (y > 50) &							// i mattoni non siano già stati eliminati
        (x < 296) & (y < 70)) ? 1'b1 : 1'b0):1'b0;
	assign brick3 =bri3 ?(((x > 346) & (y > 50) &
        (x < 410) & (y < 70)) ? 1'b1 : 1'b0):1'b0;
	assign brick4 =bri4 ?(((x > 440) & (y > 50) &
        (x < 504) & (y < 70)) ? 1'b1 : 1'b0):1'b0;
	assign brick5 =bri5 ?(((x > 184) & (y > 100) &
        (x < 248) & (y < 120)) ? 1'b1 : 1'b0):1'b0;
	assign brick6 =bri6 ?(((x > 288) & (y > 100) &
        (x < 352) & (y < 120)) ? 1'b1 : 1'b0):1'b0;
	assign brick7 =bri7 ? (((x > 392) & (y > 100) &
        (x < 456) & (y < 120)) ? 1'b1 : 1'b0):1'b0;
	assign brick8 =bri8 ? (((x > 232) & (y > 150) &
        (x < 296) & (y < 170)) ? 1'b1 : 1'b0):1'b0;
	assign brick9 =bri9 ? (((x > 346) & (y > 150) &
        (x < 410) & (y < 170)) ? 1'b1 : 1'b0):1'b0;
	assign brick10 =bri10 ? (((x > 288) & (y > 200) &
        (x < 352) & (y < 220)) ? 1'b1 :1'b0):1'b0;
	 

	
always@(*)		
begin	
	if(ok)									// nel caso di partita vinta ok è alto e viene disegnata la scritta "ok"
	begin
		B21<=((x>216)&(x<236)&(y>248)&(y<312))?1'b1:1'b0;
		B20<=((x>236)&(x<300)&(y>228)&(y<248))?1'b1:1'b0;
		B22<=((x>236)&(x<300)&(y>312)&(y<332))?1'b1:1'b0;
		B23<=((x>300)&(x<320)&(y>248)&(y<312))?1'b1:1'b0;
		B24<=((x>360)&(x<380)&(y>228)&(y<332))?1'b1:1'b0;
		B25<=((x>380)&(x<398)&(y>271)&(y<289))?1'b1:1'b0;        
		B26<=((x>398)&(x<416)&(y>243)&(y<271))?1'b1:1'b0;
		B27<=((x>416)&(x<434)&(y>235)&(y<253))?1'b1:1'b0;
		B28<=((x>398)&(x<416)&(y>289)&(y<307))?1'b1:1'b0;
		B29<=((x>416)&(x<434)&(y>307)&(y<325))?1'b1:1'b0;
		B30<=((x>434)&(x<452)&(y>325)&(y<343))?1'b1:1'b0;
		B31<=((x>434)&(x<452)&(y>217)&(y<235))?1'b1:1'b0;
		RED<= B20||B21||B22||B23;
		BLUE<= B24||B25||B26||B27||B28||B29||B30||B31;
	end
	else if(ko)								// nel caso di partita vinta ko è alto e viene disegnata la scritta "ko"
		begin
		B20<=((x>238)&(x<258)&(y>248)&(y<352))?1'b1:1'b0;
		B21<=((x>258)&(x<278)&(y>291)&(y<309))?1'b1:1'b0;
		B22<=((x>278)&(x<298)&(y>273)&(y<291))?1'b1:1'b0;
		B23<=((x>298)&(x<318)&(y>255)&(y<273))?1'b1:1'b0;
		B24<=((x>318)&(x<338)&(y>237)&(y<255))?1'b1:1'b0;
		B25<=((x>278)&(x<298)&(y>309)&(y<327))?1'b1:1'b0;
		B26<=((x>298)&(x<318)&(y>327)&(y<345))?1'b1:1'b0;
		B27<=((x>318)&(x<338)&(y>345)&(y<363))?1'b1:1'b0;
		B28<=((x>350)&(x<370)&(y>248)&(y<312))?1'b1:1'b0;
		B29<=((x>370)&(x<434)&(y>228)&(y<248))?1'b1:1'b0;
		B31<=((x>434)&(x<454)&(y>248)&(y<312))?1'b1:1'b0;
		B30<=((x>370)&(x<434)&(y>312)&(y<332))?1'b1:1'b0;
		BLUE<=B20||B21||B22||B23||B24||B25||B26||B27;
		RED<= B28||B29||B30||B31;
		end
	else
		begin
		B20<=1'b0;
		B21<=1'b0;
		B22<=1'b0;
		B23<=1'b0;
		B24<=1'b0;
		B25<=1'b0;
		B26<=1'b0;
		B27<=1'b0;
		B28<=1'b0;
		B29<=1'b0;
		B31<=1'b0;
		B30<=1'b0;
		BLUE<=1'b0;
		RED<=1'b0;
		end
		// vengono forniti i vari oggetti ai pin per il VGA																
		VGA_RED <= palla||brick1||brick2||brick3||brick4;							
		VGA_GREEN <= palla||brick8||brick9||brick10||brick7||brick6||brick5;
		VGA_BLUE <= palla||brick5||brick6||brick7||navicella;
end	 
endmodule
	
	