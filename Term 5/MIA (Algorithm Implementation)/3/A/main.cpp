
#include <iostream>
#include<vector>

using namespace std;

int n,m,v1,v2,tmp;
vector<int> cats;
vector<vector<int>> graph;

int DFS(int i,int cc,int parent){
    int sum = 0;
    bool is_Leaf = true;
    if (!cats[i]) cc = 0;
    else cc++;
    if (cc > m) return 0;
    for (int j = 0;j<graph[i].size();j++){
        if(graph[i][j] == parent) continue;
        is_Leaf = false;
        sum += DFS(graph[i][j],cc,i);
    }
    if (is_Leaf) return 1;
    return sum;
}

int main()
{
    scanf("%d %d",&n,&m);
    for (int i = 0;i<n;i++){
        scanf("%d ",&tmp);
        cats.push_back(tmp);
        graph.push_back(vector<int>());
    }
    for (int i = 0;i<n-1;i++){
        scanf("%d %d",&v1,&v2);
        graph[v1 - 1].push_back(v2 - 1);
        graph[v2 - 1].push_back(v1 - 1);
    }
    printf("%d",DFS(0,0,-1));
    return 0;
}
