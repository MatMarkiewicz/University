#include <iostream>

using namespace std;

int main()
{
    int t;
    scanf("%d",&t);
    for(int i = 0;i<t;i++){
        long long int n,m,x1,y1,x2,y2;
        scanf("%lld %lld %lld %lld %lld %lld", &n, &m,&x1,&y1,&x2,&y2);
        long long int dx = abs(x1-x2);
        long long int dy = abs(y1-y2);
        long long int rx = n - max(x1,x2) + min(x1,x2) - 1;
        long long int ry = m - max(y1,y2) + min(y1,y2) - 1;
        long long int res = 0;
        if (dx == 0){
            if (dy > ry) {
                res = (dy - ry - 1) * n;
            }
            else{
                res = 0;
            }
        }  else if (dy == 0){
            if (dx > rx) {
                res = (dx - rx - 1) * m;
            }
            else{
                res = 0;
            }
        } else{
            if (dx > rx+1 && dy > ry+1){
                res += (dx - rx - 1) * m;
                res += (dy - ry - 1) * n;
                res -= (dx - rx - 1) * (dy - ry - 1);
                dx = rx +1;
                dy = ry +1;
            }else if (dx > rx+1){
                res += (dx - rx - 1) * m;
                dx = rx +1;
            }else if (dy > ry+1){
                res += (dy - ry - 1) * n;
                dy = ry +1;
            }
            res += 2 * dy * dx;

        }
        printf("%lld\n",res);
    }
}
