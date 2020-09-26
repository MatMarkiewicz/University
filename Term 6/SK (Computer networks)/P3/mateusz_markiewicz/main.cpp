// autor: Mateusz Markiewicz 298653

#include "download.h"

using namespace std;

bool isIpAddr(char *str)
{
    struct sockaddr_in sai;
    int res = inet_pton(AF_INET, str, &(sai.sin_addr));
    return res != 0;
}

int main(int argc, char *argv[])
{
    size_t port,size;

    // sprawdzenie danych wejściowych
	if (argc != 5){
        fprintf(stderr,"Wrong number of arguments\n");
		return EXIT_FAILURE;
    } else if (!isIpAddr(argv[1])){
        fprintf(stderr,"Invalid Ip Addres: %s\n",argv[1]); 
		return EXIT_FAILURE;
    }
    if (sscanf(argv[2],"%zu",&port) != 1){
        fprintf(stderr,"Invalid second argument\n"); 
		return EXIT_FAILURE;
    }
    if (sscanf(argv[4],"%zu",&size) != 1){
        fprintf(stderr,"Invalid fourth argument\n"); 
		return EXIT_FAILURE;
    }

    try{
        // inicjalizacja
        Downloader downloader = Downloader(string(argv[1]),port,string(argv[3]),size);
        // rozpoczęcie pobierania
        downloader.download();
    }catch(const char * c){
        fprintf(stderr,"%s\n",c);
        return EXIT_FAILURE;
    };

	return EXIT_SUCCESS;
}