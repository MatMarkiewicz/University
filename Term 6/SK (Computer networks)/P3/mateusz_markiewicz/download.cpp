// autor: Mateusz Markiewicz 298653

#include "download.h"

Downloader::Downloader(string addr, size_t port, string file, size_t size){
    // przygotowanie sockfd, adresu, pliku oraz zmiennych
    this->size_of_file = size;
    this->port = port;
    this->ip_addr = addr.c_str();
    this->size_of_window = RWS;
    this->progress = 0;
    this->sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if  (this->sockfd < 0) throw "Sockfd error";
    memset(&ip_address, 0, sizeof(ip_address));
    ip_address.sin_family = AF_INET;
    ip_address.sin_port = htons(port);
    inet_pton(AF_INET, this->ip_addr, &ip_address.sin_addr);

    this->out = fopen(file.c_str(),"w");

    // inicjalizacja okna, wysłanie pierwszych zapytań
    for (size_t i=0;i<this->size_of_window;i++)
        increase_window_if_needed();
};

void Downloader::download(){
    // przygotowanie timevala
    struct timeval tv; tv.tv_sec = 0; tv.tv_usec = 20000;
    for(;;){
        // wywołujemy selecta
        fd_set descriptors;
        FD_ZERO(&descriptors);
        FD_SET(sockfd, &descriptors);
        int ready = select(sockfd + 1, &descriptors, NULL, NULL, &tv);
        if (ready < 0){
            throw "Select error";
        } else if (ready == 0){
            // nowa runda
            // wysyłamy ponownie zapytania, resetujemy czas
            for(auto datagram=current_window.begin(); datagram != current_window.end(); datagram++) datagram->send_get_request();
            tv.tv_sec = 0; tv.tv_usec = 20000;
        } else{
            // obsługa nowego pakietu
            receive_and_update();
            // Jeśli po aktualizacji nie ma już pakietów to kończymy
            if (current_window.empty()){
                fclose(out);
                return;
            }
        }
    }
};

void Downloader::increase_window_if_needed(){
    // jeśli można i jest taka potrzeba rozszerzamy okno
    if (size_of_requested < size_of_file && this->current_window.size() < this->size_of_window){
        size_t s = size_of_requested + 1000 < size_of_file ? 1000 : size_of_file - size_of_requested;
        this->current_window.push_back(Datagram(size_of_requested,s,this->sockfd,&this->ip_address));
        this->size_of_requested += s;
        this->current_window.back().send_get_request();
    }
};

void Downloader::receive_and_update(){
    // odbieramy nowy pakiet
    struct sockaddr_in sender;
    socklen_t sock_len = sizeof(sender);
    ssize_t packet_len = recvfrom(sockfd, buffer, IP_MAXPACKET, MSG_DONTWAIT, (struct sockaddr *)&sender, &sock_len);
    if (packet_len < 0) {
		throw "Reciving unsuccessful";
	}
    size_t new_start,new_len;
    // sprawdzamy, czy jest do nas i czy to pakiet z danymy
    if (ip_address.sin_addr.s_addr == sender.sin_addr.s_addr && ip_address.sin_port == sender.sin_port 
    && sscanf((char*)buffer, "DATA %zu %zu\n",&new_start, &new_len) == 2 ){
        for (auto datagram=current_window.begin(); datagram != current_window.end(); datagram++){
            // szukamy datagramu który odpowiada temu pakietowi
            if (datagram->start == new_start && datagram->len == new_len && !datagram->recieved){
                // obliczamy offset
                char message[30];
                sprintf(message, "GET %zu %zu\n", new_start, new_len);
                ssize_t message_len = strlen(message) + 1;
                char* new_data = (char*)buffer + message_len;
                for (size_t i=0;i<new_len;i++){
                    // przechowujemy tymczasowo dane
                    datagram->data[i] = new_data[i];
                }
                datagram->recieved = true;
                break;
            }
        }
    }
    // aktualizujemy okno 
    while (!current_window.empty() && current_window.front().recieved){
        fwrite(current_window.front().data,sizeof(char),current_window.front().len,this->out);

        size_of_downloaded += current_window.front().len;
        // przewusamy i rozszerzamy okno (jeśli konieczne)
        current_window.pop_front();
        increase_window_if_needed();
        // wyświetlenie informacji o post
        if ((100*size_of_downloaded)/size_of_file > progress){
            progress = (100*size_of_downloaded)/size_of_file;
            printf("%zu%%\n",progress);
        }
    }
};