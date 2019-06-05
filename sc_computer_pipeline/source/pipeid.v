module pipeid( mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
	wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
	bpc, jpc, pcsource, wpcir, dwreg, dm2reg, dwmem, daluc,
	daluimm, da, db, dimm, drn, dshift, djal );
	
	input  [4:0]  mrn, ern, wrn;
	input			  mm2reg, em2reg, mwreg, ewreg, wwreg, clock, resetn;
	input  [31:0] inst, wdi, ealu, malu, mmo, dpc4;
	output [31:0] bpc, dimm, jpc, da, db;
	output [1:0]  pcsource;
	output 		  wpcir, dwreg, dm2reg, dwmem, daluimm, dshift, djal;
	output [3:0]  daluc;
	output [4:0]  drn;
	
	wire   [31:0] q1, q2, da, db;
	wire	 [1:0]  fwda, fwdb;
	wire 			  rsrtequ = (da == db);
	wire          regrt, sext;
	wire          e = sext & inst[15];
	wire   [31:0] dimm = {{16{e}}, inst[15:0]};
	wire   [31:0] jpc = {dpc4[31:28],inst[25:0],1'b0,1'b0};
	wire   [31:0] offset = {{14{e}},inst[15:0],1'b0,1'b0};
	wire   [31:0] bpc = dpc4 + offset;
	
	regfile rf( inst[25:21], inst[20:16], wdi, wrn, wwreg, clock, resetn, q1, q2 );  //寄存器堆
	mux4x32 da_mux( q1, ealu, malu, mmo, fwda, da ); // 四选一  可能的直通
	mux4x32 db_mux( q2, ealu, malu, mmo, fwdb, db );
	mux2x5  rn_mux( inst[15:11], inst[20:16], regrt, drn );
	sc_cu cu( inst[31:26], inst[5:0], rsrtequ, dwmem, dwreg, regrt, dm2reg, daluc, dshift, daluimm, pcsource, djal, sext, wpcir, inst[25:21], inst[20:16], mrn, mm2reg, mwreg, ern, em2reg, ewreg, fwda, fwdb );//控制单元
	
endmodule