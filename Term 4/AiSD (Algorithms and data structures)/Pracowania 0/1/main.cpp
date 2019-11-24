#include <iostream>

using namespace std;

int main()
{
    int a;
    int b;
    scanf("%d",&a);
    scanf("%d",&b);
    if(b<a)
    {
        int c = a;
        a = b;
        b = c;
    }
    for(a;a<=b;a++)
    {
        printf("%d\n",a);
    }
    return 0;
}
