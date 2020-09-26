# SyK Lista 2

## Zadanie 2
Podaj  wyrażenie  zawierające  wyłącznie  zmiennexiy,  którego  wartością  logiczną  jest  wynik porównania x < y
- bez znaku: `((~x & y) | ((~x | y) & (x - y))) >> 31`
- ze znakiem: `(((x - y) ^ [(x ^ y) & ((x - y)^x)]) >> 31 ) & 1`

## Zadanie 3
Podaj fragment kodu, który oblicza funkcję abs(x):
![](https://i.imgur.com/LzQBOXK.png)
Skorzystaj z następującej własności: jeśli b jest wartością logiczną, to wyrażenie b ? x : y można przetłumaczyć do b * x + !b * y
```cpp
int abs(x) {
    int b = x >> 31;
    return ~b&x + b&(~x-1);
}
```

## Zadanie 4
Podaj fragment kodu, który oblicza funkcję sign(x):
![](https://i.imgur.com/8NHpz3q.png)
```cpp
int sign(x) {
    return 0 - ((~(x>>31)) == 0) + (((~(x>>31)) != 0) & (x != 0));
}
```

## Zadanie 5
Uzupełnij ciało funkcji zadeklarowanej poniżej.
```cpp
/* Jeśli suma x+y mieści się w typie int32_t (nie powoduje
 * nadmiaru/niedomiaru) zwróć 1, w p.p. 0*/
 int tadd_ok(int32_t x, int32_t y);
```

```cpp
int tadd_ok(int32_t x, int32_t y) {
    int32_t sum = x + y;
    int32_t overflow = (sum >> 31) != 0;
    int32_t underflow = (sum >> 31) != -1;
    return 1 - ((((x>>31) == 0) & overflow) | (((x >> 31) == -1) & underflow));
}
```

## Zadanie 6
Uzupełnij ciało funkcji zadeklarowanej poniżej.
```cpp
/* Jeśli x zawiera nieparzystą liczbę jedynek zwróć 1, w p.p. 0 */
int32_t odd_ones(uint32_t x);
```

```cpp
// x... oznacza, że sekwencja x się powtarza
// 01... -> 01010101 i tak dalej
int32_t odd_ones(uint32_t source) {
    int32_t x = source;
    x = (x & 01...) + ((x >> 1) & 01...);
    x = (x & 0011...) + ((x >> 2) & 0011...);
    x = (x & 00001111...) + ((x >> 4) & 0x0001111...);
    x = (x & 0x00ff...) + ((x >> 8) & 0x00ff...);
    x = (x & 0x0000ffff...) + ((x >> 16) & 0000ffff...);
    return x & 1;
}
```