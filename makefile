PROG = holyc

CC := gcc
CFLAGS = -O0 -static -nostdlib -ffreestanding -e _start

# https://stackoverflow.com/a/16007194/7132678
CFLAGS += -fno-asynchronous-unwind-tables

# abi conradicts the CPU?
CFLAGS += -mno-red-zone

# https://stackoverflow.com/questions/2548486/compiling-without-libc?noredirect=1&lq=1#comment109923208_2548601
CFLAGS += -mincoming-stack-boundary=4

CFLAGS += -masm=intel

default: clean $(PROG) test

$(PROG): hc.c
	$(CC) $(CFLAGS) $< -o $(PROG)

test: $(PROG) force
	./test.sh
force:

clean:
	rm -vf a.out $(PROG) *.o main

#--

a.out: $(PROG) force
	echo 42 | ./$(PROG) > $@ && chmod u+x $@
run: a.out
	./a.out ; echo $$?
disasm: a.out
	dd skip=120 bs=1 if=./$< 2> /dev/null | ndisasm -b64 -
asm: test.s
	nasm -f bin $< -o $@ && ndisasm -b64 $@
