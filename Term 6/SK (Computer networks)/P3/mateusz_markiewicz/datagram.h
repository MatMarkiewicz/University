// autor: Mateusz Markiewicz 298653

#ifndef DATAGRAM_I
#define DATAGRAM_I 1

#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>
#include <iostream>
#include <fstream>
#include <list>

class Datagram{
    public:
    size_t start, len;
    bool recieved;
    int sockfd;
    struct sockaddr_in * ip_addr;
    uint8_t data[1000];
    Datagram(size_t start, size_t len, int sockfd, struct sockaddr_in * addr);
    void send_get_request();
};

#endif