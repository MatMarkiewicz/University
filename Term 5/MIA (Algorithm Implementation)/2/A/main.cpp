#include <iostream>
#include <math.h>
#define INF 0x3f3f3f3f

using namespace std;

int main()
{
    double M,N,R,X1,X2,Y1,Y2;
    scanf("%lf %lf %lf",&M,&N,&R);
    scanf("%lf %lf %lf %lf",&X1,&Y1,&X2,&Y2);
    double A,B;
    double pi = acos(-1.0);
    A = R/N;
    if (Y1 > Y2)
    {
         swap(Y1, Y2);
         swap(X1, X2);
    }
    B = (Y1 * A * pi)/M;
    double dX = fabs(X1-X2);
    double dY = fabs(Y1-Y2);
    double res1 = A*dY + dX*B;
    double res2 = A*(Y1+Y2);
    double ans = INF * 1.0;
    ans = min(ans, res1);
    ans = min(ans, res2);
    printf("%.10f\n", ans);
    return 0;
}
