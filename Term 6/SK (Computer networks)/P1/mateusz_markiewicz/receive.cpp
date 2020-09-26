// autor: Mateusz Markiewicz 298653

#include "receive.h"

receivePacket::receivePacket(int sockfd, fd_set *descriptors){
    this->sockfd = sockfd;
    this->descriptors = descriptors;
};

int receivePacket::selcetPacket(struct timeval tv){
    FD_ZERO (descriptors);
    FD_SET (sockfd,descriptors);
    int ready = select(sockfd +1, descriptors, NULL, NULL, &tv);
    return ready;
};

packet receivePacket::reciveSinge(){
    struct sockaddr_in sender;
    socklen_t sender_len = sizeof(sender);
    u_int8_t buffer[IP_MAXPACKET];
    ssize_t packet_len = recvfrom(sockfd, buffer, IP_MAXPACKET, 0, (struct sockaddr*)&sender, &sender_len);
    if (packet_len < 0) {
		throw "Reciving unsuccessful";
	}
    char sender_ip_str[20]; 
	inet_ntop(AF_INET, &(sender.sin_addr), sender_ip_str, sizeof(sender_ip_str));
    struct ip* ip_header = (struct ip*) buffer;
    u_int8_t* icmp_packet = buffer + 4 * ip_header->ip_hl;
    struct icmp* icmp_header = ( struct icmp* )icmp_packet;
    if (icmp_header->icmp_type == ICMP_ECHOREPLY){
        return packet(sender_ip_str, icmp_header->icmp_hun.ih_idseq.icd_id, icmp_header->icmp_hun.ih_idseq.icd_seq, 
                      std::chrono::high_resolution_clock::now(), icmp_header->icmp_type);
    }else if (icmp_header->icmp_type == ICMP_TIME_EXCEEDED){
        icmp_packet += 8;
        icmp_packet += ((struct ip*) icmp_packet)->ip_hl * 4;
        struct icmp* icmp_tle = (struct icmp*) icmp_packet;
        return packet(sender_ip_str, icmp_tle->icmp_hun.ih_idseq.icd_id, icmp_tle->icmp_hun.ih_idseq.icd_seq, 
                      std::chrono::high_resolution_clock::now(), icmp_header->icmp_type);
    }
    return packet(); 
}

array<packet,3> receivePacket::reciveMulti(int id, int seq){
    int validPackets = 0;
    array<packet,3> packets;
    struct timeval tv; tv.tv_sec = 1; tv.tv_usec = 0;
    while (validPackets<3){
        int ready = selcetPacket(tv);
        if (ready<0){
            throw "Selecting unsuccessful";
        } else if (ready == 0){
            break;
        } else{
            packet p;
            try {
                p = reciveSinge();
            } catch (const char * c){
                throw c;
            }
            if (p.id == id && p.seq/3 == seq){
                packets[validPackets++] = p;
            }
        }
    }
    return packets;
}