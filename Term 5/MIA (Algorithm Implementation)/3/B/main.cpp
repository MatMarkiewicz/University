#include <iostream>
#include <bits/stdc++.h>

using namespace std;

const int N = 1e5 + 10;
char Graph[2][N];
bool visited[2][N];
int n,k,water,tmp;

bool DFS(int wall,int height){
    if (height > n) return true;
    if (Graph[wall][height] == 'X' || height < water || visited[wall][height]) return false;
    visited[wall][height] = true;
    water++;
    tmp = DFS(wall,height-1) || DFS(1-wall,height + k) || DFS(wall,height+1);
    water--;
    return tmp;
}

int main()
{
    scanf("%d %d",&n,&k);
    scanf("%s %s",Graph[0]+1,Graph[1]+1);
    water = 1;
    if (DFS(0,1)){
        printf("YES\n");
    }
    else{
        printf("NO\n");
    }
    return 0;
}
