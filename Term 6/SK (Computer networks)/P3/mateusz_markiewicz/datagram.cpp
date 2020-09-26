// autor: Mateusz Markiewicz 298653

#include "datagram.h"

Datagram::Datagram(size_t start, size_t len, int sockfd, struct sockaddr_in * addr){
    this->start = start;
    this->len = len;
    this->recieved = false;
    this->sockfd = sockfd;
    this->ip_addr = addr;
};

void Datagram::send_get_request(){
    // wysłanie zapytania o datagram
    char message[30];
    sprintf(message, "GET %zu %zu\n", start, len);
    ssize_t message_len = strlen(message);
    if (sendto(sockfd, message, strlen(message), 0, (struct sockaddr*)ip_addr, sizeof(*ip_addr)) != message_len){
        throw "Sending unsuccesseful";
    }
};
