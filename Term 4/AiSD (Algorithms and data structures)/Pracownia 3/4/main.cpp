#include <iostream>

using namespace std;

long long int exp(char e)
{
    if (e == '0') return 1;
    if (e == '1') return 7;
    if (e == '2') return 49;
    if (e == '3') return 343;
    if (e == '4') return 2401;
    if (e == '5') return 16807;
    if (e == '6') return 117649;
    if (e == '7') return 823543;
    if (e == '8') return 5764801;
    if (e == '9') return 40353607;
	return -1;
}


int main()
{
    int w;
    int k;
    scanf("%d %d",&w,&k);
    char dane [3][k+1];
    long long int res [3][k+1];
    // wczytanie pierwszych 3 wierszy danych
    for (int i = 0;i<3;i++)
    {
        scanf("%s",&dane[i]);
    }
    //czyszczenie tablic i wprowadzanie wartœci dla 1. wiersza
    for (int i = 0;i<k;i++)
    {
        res[0][i] = exp(dane[0][i]);
        res[1][i] = 0;
        res[2][i] = 0;
    }
    int w0,w1,w2;
    long long int val;
    for (int i = 2;i<w-1;i++)
    {
        w0 = i%3;
        w1 = (i-1)%3;
        w2 = (i-2)%3;

        //odczytywanie danych z ni¿szych rzêdów
        for (int j=0;j<k;j++)
        {
            val = exp(dane[w0][j]);
            if (j>0 && j<k-1)
                res[w0][j] = max(res[w0][j],max(res[w2][j+1],res[w2][j-1])+val);
            else if (j==0)
                res[w0][j] = max(res[w0][j],res[w2][j+1]+val);
            else
                res[w0][j] = max(res[w0][j],res[w2][j-1]+val);
        }

        //odczytywanie danych w wy¿szych rzêdów
        for (int j=0;j<k;j++)
        {
            val = exp(dane[w1][j]);
            if (j>1 && j<k-2)
                res[w1][j] = max(res[w1][j],max(res[w0][j+2],res[w0][j-2])+val);
            else if (j>=k-2 && j>1)
                res[w1][j] = max(res[w1][j],res[w0][j-2]+val);
            else if (j<=1 && j<k-2)
                res[w1][j] = max(res[w1][j],res[w0][j+2]+val);
        }

        //wczytanie nowych danych
        scanf("%s",&dane[(i+1)%3]);
    }
    //ostatnie wczytnie danych z dolu
    w0 = (w-1)%3;
    w2 = w%3;
    for (int j=0;j<k;j++)
    {
        val = exp(dane[w0][j]);
        if (j>0 && j<k-1)
            res[w0][j] = max(res[w0][j],max(res[w2][j+1],res[w2][j-1])+val);
        else if (j==0)
            res[w0][j] = max(res[w0][j],res[w2][j+1]+val);
        else
            res[w0][j] = max(res[w0][j],res[w2][j-1]+val);
    }

    long long int ma = 0;
    for (int i = 0;i<k;i++)
    {
        if (res[w0][i] > ma) ma = res[w0][i];
    }
    printf("%lld",ma);

    return 0;
}
