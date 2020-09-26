# autor: Mateusz Markiewicz 298653

transport : main.o download.o datagram.o
	g++ -std=gnu++17 -Wall -Wextra -o transport main.o download.o datagram.o

main.o : main.cpp

download.o: download.h download.cpp

datagram.o: datagram.h datagram.cpp

clean : 
	rm -f main.o download.o datagram.o

distclean : 
	rm -f transport main.o download.o datagram.o