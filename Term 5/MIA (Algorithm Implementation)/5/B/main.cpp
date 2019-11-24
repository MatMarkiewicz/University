#include <bits/stdc++.h>

using namespace std;

int n,m,p,b;
int A[200000];
int Tree[200000];

void built_seq_tree(int v, int l, int r, int lv){
    if (l==r) Tree[v] = A[l];
    else{
        int m = (l+r)/2;
        built_seq_tree(2*v,l,m,1-lv);
        built_seq_tree(2*v+1,m+1,r,1-lv);
        if (lv) Tree[v] = Tree[2*v] | Tree[2*v+1];
        else Tree[v] = Tree[2*v] ^ Tree[2*v+1];
    }
}

void update_seq_tree(int v, int l, int r, int p, int b, int lv){
    if (l==r) Tree[v] = b;
    else{
        int m = (l+r)/2;
        if (p <= m) update_seq_tree(2*v,l,m,p,b,1-lv);
        else update_seq_tree(2*v+1,m+1,r,p,b,1-lv);
        if (lv) Tree[v] = Tree[2*v] | Tree[2*v+1];
        else Tree[v] = Tree[2*v] ^ Tree[2*v+1];
    }
}

int main()
{
    cin >> n >> m;
    for (int i=1;i<=(1<<n);i++){
        cin >> A[i];
    }
    if (n%2 == 0) built_seq_tree(1,1,(1<<n),0);
    else built_seq_tree(1,1,(1<<n),1);
    for (int i=0;i<m;i++){
        cin >> p >> b;
        if (n%2==0) update_seq_tree(1,1,(1<<n),p,b,0);
        else update_seq_tree(1,1,(1<<n),p,b,1);
        cout << Tree[1] << endl;
    }
    return 0;
}
