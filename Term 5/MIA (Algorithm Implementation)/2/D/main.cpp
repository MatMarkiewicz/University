#include <bits/stdc++.h>

using namespace std;

typedef long long ll;
typedef vector <int> vi;
typedef pair <int, int> pi;
typedef pair <ll, ll> pl;
typedef vector < pl > vpl;


#define SIZE (3 * 1e5 + 42)

vpl Graph[ int(SIZE) ];
ll dist[ int(SIZE) ], ancestor[ int(SIZE) ];
set < pi > BAD;
ll max_ll = 1e18;

void Dijkstra(int n){
    priority_queue < pair< ll, int > > Queue;
    for (int i = 0;i<n+1;i++){
        dist[i] = max_ll;
    }

    dist[1] = 0;
    Queue.push({0, 1});

    while(!Queue.empty()){
        int act_node = Queue.top().second;
        ll act_distance = -Queue.top().first;
        Queue.pop();

        for(auto w: Graph[ act_node ]){
            ll new_dist = act_distance + w.second;
            if (dist[w.first] > new_dist){
                dist[w.first] = new_dist;
                Queue.push({-new_dist,w.first});
                ancestor[w.first] = act_node;
            }
        }
    }

    for(int i = 0;i<n;i++){
        for(auto w: Graph[i]){
            if (ancestor[i] == w.first){
                BAD.insert({i,w.first});
                break;
            }
        }
    }
}

void second_Dijkstra(int n){
    priority_queue < pair< ll, int > > Queue;
    for (int i = 0;i<n+1;i++){
        dist[i] = max_ll;
        ancestor[i] = -1;
    }
    dist[0] = 0;
    Queue.push({0, 0});

    while(!Queue.empty()){
        int act_node = Queue.top().second;
        ll act_distance = -Queue.top().first;
        Queue.pop();

        for(auto w: Graph[ act_node ]){
            ll new_dist = act_distance + w.second;
            auto it = BAD.find({act_node,w.first});
            if (dist[w.first] > new_dist and it == BAD.end()){
                dist[w.first] = new_dist;
                Queue.push({-new_dist,w.first});
                ancestor[w.first] = act_node;
            }
        }
    }

    if(dist[1] == max_ll){
        printf("impossible\n");
        return;
    }

    int goal = 1;
    vi answer;
    while (goal != 0){
        answer.push_back(goal);
        goal = ancestor[ goal ];
    }
    answer.push_back(0);
    reverse(answer.begin(),answer.end());
    printf("%d ",answer.size());
    for (auto a: answer){
        printf("%d ",a);
    }
    printf("\n");
}

int main()
{
    int n,m;
    scanf("%d %d",&n,&m);
    int a,b,c;
    for (int i = 0;i<m;i++){
        scanf("%d %d %d",&a,&b,&c);
        Graph[a].push_back({b,c});
        Graph[b].push_back({a,c});
    }

    Dijkstra(n);
    second_Dijkstra(n);

    return 0;
}
