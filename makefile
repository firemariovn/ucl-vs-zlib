all: build run
build:
	gcc -O2 -o benchmark benchmark.c -lucl -lz

run:
	./benchmark sample.txt
	#./benchmark VietnamMusic006.wav
