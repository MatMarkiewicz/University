#include <iostream>
#include <algorithm>
#include <cmath>

using namespace std;


class elem
{
    public:
        int x;
        int y;
        bool operator ==(const elem &e) {return x == e.x && y==e.y;}
        bool operator !=(const elem &e) {return x != e.x || y!=e.y;}
        bool operator <(const elem &e) {return x < e.x || (x == e.x && y < e.y) ;}
        bool operator <=(const elem &e) {return x <= e.x || (x == e.x && y <= e.y);}
        bool operator >=(const elem &e) {return x >= e.x || (x == e.x && y >= e.y);}
        bool operator >(const elem &e) {return x > e.x || (x == e.x && y > e.y);}
        elem(int x = 0, int y = 0)
        {
            this->x = x;
            this->y = y;
        }
};

double dis(int x1, int y1, int x2, int y2)
{
    double d = sqrt(pow(((long long int) x2)-((long long int) x1), 2) + pow(((long long int) y2)-((long long int) y1), 2));
    return d;
};

typedef struct pair_of_elem {
    elem e1;
    elem e2;
    double dist;
} Pair;

bool comp1(elem e1, elem e2)
{
    return e1 < e2;
};

bool comp2(elem e1, elem e2)
{
    return e1.y < e2.y;
};

bool comp3(pair_of_elem p1, pair_of_elem p2)
{
    return p1.dist < p2.dist;
};

Pair nearest(elem X[],int xp,elem Y[],int n)
{
    if (n<7){
        Pair R[22];
        int p = 0;
        for (int i=0;i<n;i++)
        {
            for (int j=i+1;j<n;j++)
            {
                Pair pa;
                pa.e1 = X[xp+i];
                pa.e2 = X[xp+j];
                pa.dist = dis(X[xp+i].x,X[xp+i].y,X[xp+j].x,X[xp+j].y);
                R[p] = pa;
                p++;
            }
        }
        sort(R,R+p,comp3);
        return R[0];
    }

    int l = X[xp+n/2].x;
    elem sp = X[xp+n/2];
    elem Y1[n/2];
    elem Y2[n - n/2];
    int i1=0;
    int i2=0;
    for (int i=0;i<n;i++)
    {
        if(Y[i] < sp){
            Y1[i1] = Y[i];
            i1++;
        }
        else{
            Y2[i2] = Y[i];
            i2++;
        }
    }
    Pair p1 = nearest(X,xp,Y1,n/2);
    Pair p2 = nearest(X,xp+n/2,Y2,n-n/2);
    Pair ret;
    if (p1.dist<p2.dist)
        ret = p1;
    else
        ret = p2;
    int k = 0;
    for (int i = 0;i<n;i++)
    {
        if (abs(Y[i].x - l) < ret.dist)
        {
            Y[k] = Y[i];
            k++;
        }
    }
    for (int i=0;i<k;i++)
    {
        for (int j = i+1;j<i+8 & j<k;j++)
        {
            double d1 = dis(Y[i].x,Y[i].y,Y[j].x,Y[j].y);
            if (d1 < ret.dist)
            {
                ret.e1 = Y[i];
                ret.e2 = Y[j];
                ret.dist = d1;
            }
        }
    }
    return ret;
};


int main()
{
    int n;
    scanf("%d",&n);
    elem X[n];
    elem Y[n];
    int x,y;
    for (int i=0;i<n;i++)
    {
        scanf("%d %d",&x,&y);
        X[i] = elem(x,y);
    }
    sort(X,X+n,comp1);
    copy(X,X+n,Y);
    sort(Y,Y+n,comp2);
    Pair res = nearest(X,0,Y,n);
    //printf("%.5f\n",res.dist);
    printf("%d %d\n",res.e1.x,res.e1.y);
    printf("%d %d\n",res.e2.x,res.e2.y);
    return 0;
}
