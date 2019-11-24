#include <iostream>

using namespace std;

#define N 1010
char m[N][N];
bool vd[N];
int res[N];
int tot,n;

void DFS(int v){
    vd[v] = true;
    res[tot++] = v;
    for(int i = 0; i<n; i++)
    {
        if(m[v][i] == '1' && !vd[i])
        {
            DFS(i);
        }
    }
}

int main()
{
    scanf("%d",&n);
    for (int i = 0;i<n;i++){
        for (int j = 0;j<n;j++){
            scanf(" %c",&m[i][j]);
        }
        vd[i] = false;
    }
    tot = 0;
    DFS(0);
    if (tot != n){
        puts("impossible");
    }
    else{
        for(int i = n-1; i >= 0; i--){
                printf("%d%c", res[i], " \n"[i == 0]);
            }
    }

    return 0;
}
