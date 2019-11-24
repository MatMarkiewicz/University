#include <iostream>
#include <algorithm>

using namespace std;

int main()
{
    int n;
    int arr[20];
    int res[2] = {0, 0};
    scanf("%d",&n);
    for (int i = 1; i <= n; ++i) scanf("%d", arr + i);
    sort(arr + 1, arr + 1 + n);
    int flag = 0;
    for (int i = n; i >= 1; --i)
    {
        res[flag] += arr[i];
        flag ^= 1;
    }
    printf("%d %d\n", max(res[0], res[1]), min(res[0], res[1]));
    return 0;
}
