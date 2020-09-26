// autor: Mateusz Markiewicz 298653

#ifndef DOWNLOADER_I
#define DOWNLOADER_I 1

#include "datagram.h"

using namespace std;

#define RWS 750;

class Downloader{
    public:
    size_t size_of_file, size_of_window, port, size_of_downloaded, size_of_requested, progress;
    int sockfd;
    const char * ip_addr;
    struct sockaddr_in ip_address;
    FILE *out;
    u_int8_t buffer[IP_MAXPACKET+1];
    list <Datagram> current_window;
    Downloader(string addr, size_t port, string file, size_t size);
    void download();
    void increase_window_if_needed();
    void receive_and_update();
};

#endif