#include <iostream>
using namespace std;

class elem
{
    public:
        int x;
        int y;
        bool operator ==(const elem &e) {return x == e.x && y==e.y;}
        bool operator !=(const elem &e) {return x != e.x || y!=e.y;}
        bool operator <(const elem &e) {return ((long long int) x) * ((long long int) y) < ((long long int) e.x) * ((long long int) e.y) ;}
        bool operator <=(const elem &e) {return ((long long int) x) * ((long long int) y) <= ((long long int) e.x) * ((long long int) e.y) ;}
        bool operator >=(const elem &e) {return ((long long int) x) * ((long long int) y) >= ((long long int) e.x) * ((long long int) e.y) ;}
        bool operator >(const elem &e) {return ((long long int) x) * ((long long int) y) > ((long long int) e.x) * ((long long int) e.y) ;}
        elem(int x = 0, int y = 0)
        {
            this->x = x;
            this->y = y;
        }
};

class heap
{
    // Napisane na podstawie notatek z wyk³adu
    public:
        elem A[1100000];
        int e;
        int k;
        int j;
        heap()
        {
            this->e = 0;
        }
        void move_down(int i)
        {
            k = i;
            j = -1;
            while (j!=k)
            {
                j = k;
                if (2*j<=e && A[2*j] > A[k]) k = 2*j;
                if (2*j<e && A[2*j + 1] > A[k]) k = 2*j +1;
                elem sw = A[j];
                A[j] = A[k];
                A[k] = sw;
            }
        }
        void move_up(int i)
        {
            k = i;
            j = -1;
            while (j!=k)
            {
                j = k;
                if (j > 1 && A[j/2] < A[k]) k = j/2;
                elem sw = A[j];
                A[j] = A[k];
                A[k] = sw;
            }
        }
        void add(elem el)
        {
            ++e;
            A[e] = el;
            move_up(e);
        }
        elem pop()
        {
            elem top = A[1];
            A[1] = A[e];
            --e;
            move_down(1);
            return top;
        };
};


int main()
{
    int n;
    int k;
    scanf("%d %d",&n,&k);
    elem lpe = elem(n,n);
    long long int last_prod = ((long long int) lpe.x) * ((long long int) lpe.y);
    printf("%lld\n",last_prod);
    --k;
    heap pq = heap();
    pq.add(elem(n-1,n));
    while (k>0)
    {
        elem act = pq.pop();
        if (act != lpe)
        {
            if (act.y == n && act.x > 1)
            {
                pq.add(elem(act.x-1,act.y));
            }
            if (act.x < act.y)
            {
                pq.add(elem(act.x,act.y-1));
            }
            if (act < lpe)
            {
                lpe = act;
                last_prod = ((long long int) lpe.x) * ((long long int) lpe.y);
                printf("%lld\n",last_prod);
                --k;
            }
        }
    }
    return 0;
}
