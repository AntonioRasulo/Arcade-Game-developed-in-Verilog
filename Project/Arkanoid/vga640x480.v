module vga640x480(
    input wire i_clk,           // clock
    input wire i_pix_stb,       // clock dei pixel
    input wire i_rst,           // reset
    output wire o_hs,           // sync orizzontale
    output wire o_vs,           // sync verticale
    output wire o_animate,      // alto quando vengono disegnati i pixel attivi (pixel dello schermo)
    output wire [9:0] o_x,      // posizione x del pixel corrente
    output wire [8:0] o_y       // posizione y del pixel corrente
    );

    localparam HS_STA = 16;              // inizio sync orizzontale
    localparam HS_END = 16 + 96;         // fine sync orizzontale
    localparam HA_STA = 16 + 96 + 48;    // inizio dei pixel in orizzontale attivi (lato sx dello schermo)
    localparam VS_STA = 480 + 10;        // inizio sync verticale
    localparam VS_END = 480 + 10 + 2;    // fine sync verticale
    localparam VA_END = 480;             // fine dei pixel in verticale attivi (lato in basso dello schermo)
    localparam LINE   = 800;             // riga di pixel completa 
    localparam SCREEN = 525;             // colonna di pixel completa 

    reg [9:0] h_count;  // posizione riga
    reg [9:0] v_count;  // posizione colonna

    // generazione dei segnali di sync (sono attivi bassi per 640x480)
    assign o_hs = ~((h_count >= HS_STA) & (h_count < HS_END));
    assign o_vs = ~((v_count >= VS_STA) & (v_count < VS_END));

    // si mantengono x ed y all'interno dei pixel attivi (pixel dello schermo)
    assign o_x = (h_count < HA_STA) ? 0 : (h_count - HA_STA);
    assign o_y = (v_count >= VA_END) ? (VA_END - 1) : (v_count);

    // animate: alto quando vengono disegnati i pixel attivi (pixel dello schermo)
    assign o_animate = ((v_count == VA_END - 1) & (h_count == LINE));

    always @ (posedge i_clk)
    begin
        if (i_rst)  // reset
        begin
            h_count <= 0;
            v_count <= 0;
        end
        if (i_pix_stb)  // per ogni pixel
        begin
            if (h_count == LINE)  // nel caso di fine della linea, va all'inizio della linea successiva 
            begin
                h_count <= 0;
                v_count <= v_count + 10'b 1;
            end
            else 
                h_count <= h_count + 10'b 1;		//altrimenti va al pixel successivo sulla stessa linea

            if (v_count == SCREEN)  // fine dello schermo => si torna alla prima linea
                v_count <= 0;
        end
    end
endmodule