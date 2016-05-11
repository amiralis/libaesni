linux:
	yasm -D__linux__ -f elf64 asm/iaesx64.s -o iaesx64.o
	yasm -D__linux__ -f elf64 asm/do_rdtsc.s -o do_rdtsc.o
	gcc -Wall -fPIC -c intel_aes.c -o intel_aes.o 
	gcc -shared -o libaes_lin64.so *.o

mac:
	yasm -D__linux__ -f macho64 asm/iaesx64.s -o iaesx64.o
	yasm -D__linux__ -f macho64 asm/do_rdtsc.s -o do_rdtsc.o
	gcc -Wall -fPIC -c intel_aes.c -o libaesniintel_aes.o 
	gcc -shared -o libaes_mac64.so *.o	


clean:
	rm *.o

test:
	gcc -Wall -c test_libaesni.c -o test_libaesni.o
	gcc -o test_libaesni *.o
	