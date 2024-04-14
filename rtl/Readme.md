# Readme

## Required tools setup

### OSS CAD suite
This toolchain is used for RTL synthesys of Verilog code for Lattice ECP5 FPGA that is used in ULX3S board. To install it just download and extract latest binary release from github [page](https://github.com/YosysHQ/oss-cad-suite-build). To use it just go to extracted folder and type:
```
soure environment 
```

## Project structure
	- control_decoder.v
	- build.ys - yosys build script
	- Makefile

## Building project
Navigate to rtl folder of project repo and type:
``` make ```