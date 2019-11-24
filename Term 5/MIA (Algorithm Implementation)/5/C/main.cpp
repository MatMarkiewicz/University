#include <bits/stdc++.h>

using namespace std;

int q,x,n,a,b,c;
char d;
string s;
int A[100010];
int Tree[400010];

void built_seq_tree(int v, int l, int r){
    if (l==r) Tree[v] = A[l];
    else{
        int m = (l+r)/2;
        built_seq_tree(2*v,l,m);
        built_seq_tree(2*v+1,m+1,r);
        Tree[v] = Tree[2*v] | Tree[2*v+1];
    }
}

void update_seq_tree(int v, int l, int r, int p, int b){
    if (l==r) Tree[v] = b;
    else{
        int m = (l+r)/2;
        if (p <= m) update_seq_tree(2*v,l,m,p,b);
        else update_seq_tree(2*v+1,m+1,r,p,b);
        Tree[v] = Tree[2*v] | Tree[2*v+1];
    }
}


int sum_seq_tree(int v, int l, int r, int p, int b){
    if (p>b) return 0;
    if (l==p && r==b) return Tree[v];
    int m = (l+r)/2;
    return ( sum_seq_tree(2*v,l,m,p,min(b,m)) | sum_seq_tree(2*v+1,m+1,r,max(p,m+1),b) );
}

int main()
{
    cin >> s >> q;
    n = s.size();
    for (int i=0;i<n;i++){
        x = s[i] - 'a';
        x = pow(2,x);
        A[i] = x;
    }
    built_seq_tree(1,0,n-1);
    for (int i=0;i<q;i++){
        cin >> a >> b;
        if (a==1){
            cin >> d;
            x = d - 'a';
            x = pow(2,x);
            update_seq_tree(1,0,n-1,b-1,x);
        }
        else{
            cin >> c;
            int sum = sum_seq_tree(1,0,n-1,b-1,c-1);
            int res = 0;
            while (sum != 0){
                if (sum%2) res++;
                sum /= 2;
            }
            cout << res << endl;
        }
    }
    return 0;
}
