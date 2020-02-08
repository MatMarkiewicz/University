#include <iostream>
using namespace std;


int A[100];
int B[100];

int main()
{
    int n,m,a,b,k,i,j;
    int res=0;
    cin >> n >> m;
    for (i=1;i<=n;i++){
        scanf("%d",&a);
        k = 0;
        while(a){
            A[k] += a%2;
            a/=2;
            k++;
        }
    }
    for (i=1;i<=m;i++){
        scanf("%d",&b);
        B[b]++;
    }
    for (i=0;i<32;i++){
        while(B[i]){
            for (j=i;j<32;j++)
                if(A[j]) break;
            if(A[j]){
                B[i]--;
                A[j]--;
                while(j>i){
                    j--;
                    A[j]++;
                }
                res++;
            }
            else{
                break;
            }
        }
    }

    cout << res << endl;
    return 0;
}


