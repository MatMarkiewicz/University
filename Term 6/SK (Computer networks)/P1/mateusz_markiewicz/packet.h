// autor: Mateusz Markiewicz 298653

#include <chrono>

const uint8_t EMPTY_PACKET_TYPE = 100;

class packet{
    public:
    char* ip_str;
    int id;
    int seq;
    uint8_t type;
    std::chrono::high_resolution_clock::time_point time;
    packet();
    packet(char * ip_str,int id, int seq, std::chrono::high_resolution_clock::time_point time, uint8_t type);
};