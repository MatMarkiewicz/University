// autor: Mateusz Markiewicz 298653

#include "sender.h"
#include "receive.h"

bool isIpAddr(char *str)
{
    struct sockaddr_in sai;
    int res = inet_pton(AF_INET, str, &(sai.sin_addr));
    return res != 0;
}

int main(int argc, char *argv[])
{
	if (argc != 2){
        fprintf(stderr,"Wrong number of arguments\n"); 
		return EXIT_FAILURE;
    } else if (!isIpAddr(argv[1])){
        fprintf(stderr,"Invalid Ip Addres: %s\n",argv[1]); 
		return EXIT_FAILURE;
    }

    int sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
    sendPacket sender = sendPacket(sockfd, argv[1]);
    fd_set descriptors;
    receivePacket receiver = receivePacket(sockfd, &descriptors);
    for (int ttl=1; ttl<=30; ttl++){
        std::chrono::high_resolution_clock::time_point sendtime = std::chrono::high_resolution_clock::now();
        int pid = -1;
        try{
            pid = sender.sendMulti(ttl);
        } catch(const char * c){
            fprintf(stderr,"%s\n",c);
            return EXIT_FAILURE;
        }
        array<packet,3> packets;
        try{
            packets = receiver.reciveMulti(pid,ttl-1);
        } catch (const char * c){
            fprintf(stderr,"%s\n",c);
            return EXIT_FAILURE;
        }
        if (packets[0].id == -1){
            printf("*\n");
        }else {
            unsigned int whole_time = 0;
            set<char*> S;
            for (int i=0;i<3;i++){
                packet p = packets[i];
                if (p.id != -1){
                    S.insert(p.ip_str);
                    whole_time += std::chrono::duration_cast<std::chrono::milliseconds>(p.time - sendtime).count();
                }
            }
            for (char * const& ipstr : S) printf("%s ",ipstr);
            if (packets[2].id != -1){
                printf("%ums\n",whole_time/3);
            }else{
                printf("???\n");
            }
            if (packets[0].type == ICMP_ECHOREPLY){
                break;
            }
        }

    }
	return EXIT_SUCCESS;
}
