// autor: Mateusz Markiewicz 298653

#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>
#include <iostream>
#include <set>
#include <array>
#include "packet.h"

using namespace std;


class receivePacket{
    public:
    int sockfd;
    fd_set *descriptors;

    receivePacket(int sockfd, fd_set *descriptors);

    int selcetPacket(struct timeval tv);
    packet reciveSinge();
    array<packet,3> reciveMulti(int id, int seq);

};

