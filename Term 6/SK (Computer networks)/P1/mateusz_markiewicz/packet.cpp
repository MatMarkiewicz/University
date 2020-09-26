// autor: Mateusz Markiewicz 298653

#include "packet.h"

packet::packet(){
    this->ip_str = nullptr;
    this->id = -1;
    this->seq = -1;
    this->time = std::chrono::high_resolution_clock::now();
    this->type = EMPTY_PACKET_TYPE;
}

packet::packet(char * ip_str,int id, int seq, std::chrono::high_resolution_clock::time_point time, uint8_t type){
    this->ip_str = ip_str;
    this->id = id;
    this->seq = seq;
    this->time = time;
    this->type = type;
}