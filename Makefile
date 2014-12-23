all : gpu.exe


gpu.exe: BigInteger.cu
	nvcc  $< -o $@ --compiler-options -O2 -arch sm_21

clean:
	rm -rf *.exe

