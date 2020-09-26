# SyK Lista 1

## Zadanie 1
Napisz fragment kodu (w języku C), który dla zmiennych x i k wykona poniższe operacje:
- wyzeruje k-ty bit zmiennej x: `x &= ~(1 << k)`
- ustawi k-ty bit zmiennej x: `x |= (1 << k)`
- zaneguje k-ty bit zmiennej x: `x ^= (1 << k)`

## Zadanie 2
Napisz fragment kodu, który dla zmiennych x i y obliczy poniższe wyrażenia:
- $x*2^{y}$: `x << y`
- $floor(x/2^{y})$: `x >> y`
- $x mod 2^{y}$: 
    ```
    div = x >> y;
    p = div << y;
    return x - p
    ```
- $ceil(x/2^{y})$: Korzystamy z $floor(\frac{a+b-1}{b}) = ceil(\frac{a}{b})$
    - czytelniej: `(x + (1 << y) - 1) >> y`
    - krócej: `((x - 1) >> y) + 1`

## Zadanie 3
Napisz fragment kodu, który bez użycia dodatkowych zmiennych, zamieni miejscami zawartość zmiennych x i y
```cpp
void swap(int &x, int&y) {
    x = x + y;
    y = x - y;
    x = x - y;
}
```

## Zadanie 4
Brak

## Zadanie 5
Napisz fragment kodu, który stwierdza czy dana liczba x nie jest potęgą dwójki
`(((x >> 1) - (~x&1)) >> 31 | (x & (x-1))`

## Zadanie 6
Zmienne i, k spełniają  warunek 0≤i,  k≤31.  Napisz  fragment  kodu,  który  skopiuje i-ty  bit zmiennej x na pozycję k-tą
- v1:
    ```cpp
    void copyIthBitToKthPosition(unsigned int &x, int i, int k) {
        unsigned int iToKBit = ((x >> i) << 31) >> (31 - k);
        x &= ~(1 << k); // zerujemy k-ty bit
        x |= iToKBit;   // wstawiamy i-ty bit na k-te miejsce
    }
    ```
- v2:
    ```
    (((x >> i) & 1) << k) | (x & ~(1 << k))
    ```

## Zadanie 7
Napisz fragment kodu, który wyznaczy liczbę zapalonych bitów w zmiennej x
```cpp
unsinged int activeBits(unsigned int source) {
    unsigned int x = source;
    x = (x & 0x55...5) + ((x >> 1) & 0x55...5);
    x = (x & 0x33...3) + ((x >> 2) & 0x33...3);
    x = (x & 0x0f..0f) + ((x >> 4) & 0x0f..0f);
    x = (x & 0x00ff..) + ((x >> 8) & 0x00ff..);
    x = (x & 0xffff) + ((x >> 16) & 0xffff);
    return x;
}
```

## Zadanie 8
Napisz  fragment  kodu,  który  skonwertuje  zmienną x z  formatu little-endian do  formatu big-endian. Należy użyć jak najmniejszej liczby operacji bitowych
- v1:
    ```cpp
    b1 = x >> 24; // 000a
    b2 = x << 24; // d000
    b3 = (x >> 8) & 0xff00; // 00b0
    b4 = (x << 8) & 0xff00; // 0c00
    return b1 | b2 | b3 | b4
    ```
- v2:
    ```cpp
    x = ((x << 8) & 0xff00ff00) | ((x >> 8) & 0x00ff00ff);
    x = (x << 16) | (x >> 16);
    ```