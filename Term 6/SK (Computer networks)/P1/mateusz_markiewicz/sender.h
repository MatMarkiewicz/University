// autor: Mateusz Markiewicz 298653

#include <unistd.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <arpa/inet.h>
#include <cassert>
#include <strings.h>
#include <stdio.h>
#include <iostream>

using namespace std;

class sendPacket{
    public:
    int sockfd;
    char * ip;

    sendPacket(int sockfd, char* ip);

    void sendSingle(int ttl,int id, int pid);
    int sendMulti(int ttl);
};

u_int16_t compute_icmp_checksum (const void *buff, int length);
