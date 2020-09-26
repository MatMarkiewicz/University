// autor: Mateusz Markiewicz 298653

#include "sender.h"

sendPacket::sendPacket(int sockfd, char* ip){
    this->sockfd = sockfd;
    this->ip = ip;
};

void sendPacket::sendSingle(int ttl,int id, int pid){
    struct icmp header;
    header.icmp_type = ICMP_ECHO;
    header.icmp_code = 0;
    header.icmp_hun.ih_idseq.icd_id = pid;
    header.icmp_hun.ih_idseq.icd_seq = id;
    header.icmp_cksum = 0;
    header.icmp_cksum = compute_icmp_checksum ((u_int16_t*)&header, sizeof(header));
    struct sockaddr_in recipient;
    bzero (&recipient, sizeof(recipient));
    recipient.sin_family = AF_INET;
    inet_pton(AF_INET, this->ip, &recipient.sin_addr);
    int setsockoptres = setsockopt(sockfd, IPPROTO_IP, IP_TTL, &ttl, sizeof(int));
    if (setsockoptres < 0){
        throw "Sending unsuccesseful";
    }
    ssize_t bytes_sent = sendto (sockfd, &header, sizeof(header), 0, (struct sockaddr*)&recipient, sizeof(recipient));
    if (bytes_sent < 0){
        throw "Sending unsuccesseful";
    }
};

int sendPacket::sendMulti(int ttl){
    int pid = getpid();
    for (int i=0;i<3;i++){
        sendSingle(ttl,(ttl-1)*3+i,pid);
    };
    return pid;
};

u_int16_t compute_icmp_checksum (const void *buff, int length){
    u_int32_t sum;
	const u_int16_t* ptr = (const u_int16_t *) buff;
	assert (length % 2 == 0);
	for (sum = 0; length > 0; length -= 2)
		sum += *ptr++;
	sum = (sum >> 16) + (sum & 0xffff);
	return (u_int16_t)(~(sum + (sum >> 16)));
}