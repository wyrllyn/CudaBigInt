all : gpu.exe


gpu.exe: main.cu BigInteger.o utility.o kernel.o
	nvcc $< -o $@ --compiler-options -O2 BigInteger.o utility.o kernel.o -arch sm_21

BigInteger.o: BigInteger.cu
	nvcc $< -c --compiler-options -O2 -arch sm_21

utility.o: utility.cu
	nvcc $< -c --compiler-options -O2 -arch sm_21

kernel.o: kernel.cu
	nvcc $< -c --compiler-options -O2 -arch sm_21

clean:
	rm -rf *.o
	rm -rf *.exe

