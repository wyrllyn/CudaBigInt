all : gpu.exe


gpu.exe: main.cu BigInteger.o
	nvcc  $< -o $@ --compiler-options -O2 -arch sm_21 BigInteger.o

BigInteger.o: BigInteger.cu
		nvcc  $< -c --compiler-options -O2 -arch sm_21

clean:
	rm -rf *.exe

