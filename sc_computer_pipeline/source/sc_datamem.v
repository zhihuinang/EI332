/*
module sc_datamem (addr,datain,dataout,we,clock);
 
   input  [31:0]  addr;
   input  [31:0]  datain;
   
   input          we, clock;
   output [31:0]  dataout;
   
   wire           write_enable; 
   assign         write_enable = we & clock; 
   
   lpm_ram_dq_dram  dram(addr[6:2],clock,datain,write_enable,dataout );

endmodule 
*/

module sc_datamem (resetn,addr,datain,dataout,we,clock,in_port0_tmp,in_port1_tmp,in_portsub_tmp,out_port0,out_port1,out_port2,LEDR4);

   input  [31:0]  addr;
   input  [31:0]  datain;
   input          we, clock, in_portsub_tmp;
	input [3:0]	in_port0_tmp, in_port1_tmp;
	output [31:0]	out_port0, out_port1, out_port2;
   output [31:0]  dataout;
   output         LEDR4;
	input				resetn;
	wire [31:0]		mem_dataout,io_read_data;
   wire           write_enable, write_io_enable, write_datamem_enable;
   wire [31:0] in_port0,in_port1,in_port_sub;
   assign in_port0={28'b0,in_port0_tmp};
   assign in_port1={28'b0,in_port1_tmp};
	assign in_port_sub={31'b0,in_portsub_tmp};


   assign         write_enable = we ; 
   assign 			write_io_enable = addr[7] & write_enable;
	assign			write_datamem_enable = ~addr[7] & write_enable;

   mux2x32 mem_io_dataout_mux(mem_dataout,io_read_data,addr[7],dataout);
   // module mux2x32 (a0,a1,s,y);
   // when address[7]=0, means the access is to the datamem.
   // that is, the address space of datamem is from 000000 to 011111 word(4 bytes)
	lpm_ram_dq_dram dram(addr[6:2],clock,datain,write_datamem_enable,mem_dataout);
   // when address[7]=1, means the access is to the I/O space.
   // that is, the address space of I/O is from 100000 to 111111 word(4 bytes)
   io_output_reg io_output_regx2(addr,datain,write_io_enable,clock,resetn,out_port0,out_port1,out_port2,LEDR4);
	// module io_output_reg (addr,datain,write_io_enable,io_clk,clrn,out_port0,out_port1 );
   io_input_reg io_input_regx2(addr,clock,io_read_data,in_port0,in_port1,in_port_sub);
	// module io_input_reg (addr,io_clk,io_read_data,in_port0,in_port1);
endmodule