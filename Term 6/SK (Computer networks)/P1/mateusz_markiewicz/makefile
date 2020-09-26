# autor: Mateusz Markiewicz 298653

traceroute : main.o packet.o receive.o sender.o
	g++ -std=gnu++17 -Wall -Wextra -o traceroute main.o packet.o sender.o receive.o

main.o : main.cpp

packet.o : packet.h packet.cpp

sender.o : sender.h sender.cpp 

receive.o : receive.h receive.cpp

clean : 
	rm -f main.o packet.o receive.o sender.o

distclean : 
	rm -f traceroute main.o packet.o receive.o sender.o