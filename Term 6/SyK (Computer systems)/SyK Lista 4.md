# SyK Lista 4

## Zad. 1
[https://docs.oracle.com/cd/E19455-01/806-3773/instructionset-120/index.html](https://docs.oracle.com/cd/E19455-01/806-3773/instructionset-120/index.html)
setb - set byte if below (unsigned), CF
setl - set byte if less (signed), SF^OF
flagi:
* CF=1 if carry out from MSB (used for unsigned comparison)
* SF=1 if (b-a) < 0 (signed)
* OF=1 if two’s complement (signed) overflow
(b>0 && a<0 && (b-a)<0) || (b<0 && a>0 && (b-a)>0)

Gdy robimy cmp a b to tak naprawdę liczmy b-a

1) dla signed (setl):
    * a>=0 && b>=0
    Nie może wystąpić overflow, więc b-a jest takie, jak       powinno
        * a>b 
        b-a<0 więc SF=1, OF=0, SF^OF=1, setl ustawia 1, a           b jest mniejsze niż a, więc działa zgodnie z               oczekiwaniem
        * a\<=b
        b-a>=0 więc SF=0, OF=0, SF^OF=0, setl ustawia 0, a         b nie jest mniejsze niż a, więc działa zgodnie z           oczekiwaniem
    * a>=0 && b<0
    Jeśli wystąpi overflow (różnica będzie dodatnia,           chociaż nie powinna), wtedy SF=0, ale OF=1, więc           SF^OF=1, więc setl zadziała poprawnie  
    Jeśli overflow nie wystąpi, wtedy SF=1, ale OF=0, więc     setl nadal działa poprawnie
    * a<0 && b>=0
    Jeśli wystąpi overflow (różnica będzie ujemna,             chociaż nie powinna), wtedy SF=1, ale OF=1, więc           SF^OF=0, więc setl zadziała poprawnie  
    Jeśli overflow nie wystąpi, wtedy SF=0 oraz OF=0, więc     setl nadal działa poprawnie
    * a<0 && b<0
    Nie może wystąpić overflow, więc b-a jest takie, jak       powinno
        * a>b 
        b-a<0 więc SF=1, OF=0, SF^OF=1, setl ustawia 1, a           b jest mniejsze niż a, więc działa zgodnie z               oczekiwaniem
        * a\<=b
        b-a>=0 więc SF=0, OF=0, SF^OF=0, setl ustawia 0, a         b nie jest mniejsze niż a, więc działa zgodnie z           oczekiwaniem
2) dla unsigned (setb)
    * a<=b
    b-a wykona się poprawnie, nie zależnie od wielkości a       oraz b (nie może nastąpić pożyczenie z najbardziej         znaczącego bitu, ponieważ byłoby to zaprzeczeniem, że       a<=b), stąd CF=0, stąd setb zadziała zgodnie z             przewidywaniem
    * a>b
    W takim przypadku konieczne jest pożyczenie z bitu,         który jest już poza długością liczby, niezależnie ile       ta długośc wynosi (następuje carry), stąd zapali sie       CF, więc setb ustawi 1, się zadziała zgodnie z             oczekiwaniem
    
## Zad. 2
```
void who(short v[], size_t n)

who:
    subq $1, %rsi              // n = n - 1
    movl $0, %eax              // i = 0
.L2: cmpq %rsi, %rax           // |
    jnb .L4                    // while (i <= n)
    leaq (%rdi, %rax, 2), %rcx // |
    movzwl (%rcx), %r8d        // x = rdi[i]
    leaq (%rdi, %rsi, 2), %rdx // |
    movzwl (%rdx), %r9d        // y = rdi[n]
    movw %r9w, (%rcx)          // rdi[i] = y
    movw %r8w, (%rdx)          // rdi[n] = x
    addq $1, %rax              // i++
    subq $1, %rsi              // n--
    jmp .L2
.L4: ret
```
Zatem
```
void who(short v[], size_t n) {
    for (int i = 0, j = n - 1; i <= j; i++, j--) {
        short temp = v[i];
        v[i] = v[j];
        v[j] = temp;
    }
}
```
Czyli odwrócenie kolejności w tablicy.
Znajomość sygnatury nie jest istotna, gdyż widać że mamy do czynienia z tablicą, 
a instrukcje movW wskazują, że operujemy na shortach.


## Zad. 3

```
bool zonk(char * a, char* b)

zonk:
    movl $0, %ecx              // rcx = 0;
.L2: movslq %ecx, %rax         // long long rax = rcx;
    movzbl (%rdi, %rax), %edx  // rdx = rdi[rax];
    testb %dl, %dl             // |
    je .L6                     // if (dl == 0) { jump L6 }  
    cmpb %dl, (%rsi, %rax)     // 
    jne .L5                    // if (rdi[rax] != rsi[rax]) { jump L5 }
    addl $1, %ecx              // rcx++
    jmp .L2
.L6: orb (%rsi, %rax), %dl     // return (rdi[rax] | rsi[rax]) == 0
    sete %al
    ret
.L5: movl $0, %eax             // return false
    ret
```
Zatem 
```
bool zonk(char * a, char* b) {
    int i = 0;
    while (true) {
        char x = *(a + i);
        char y = *(b + i);
        if (x == '\0') {
            return x == y;
        }
        if (x != y) {
            return false;
        }
        ++i;
    }
}
```

Funkcja sprawdza, czy stringi (łańcuchy znaków) a i b są sobie równe.

## Zad 4

```
pusq src:
    subq $8, %rsp
    movq src, (%rsp)
    
popq dest:
    movq (%rsp), dest
    addq $8, %rsp
```

## Zad. 5
```
foo(int16_t v[], size_t n)

foo:    
    pushq   %rbp            // |
    movq    %rsp, %rbp      // |
    movq    %rdi, -24(%rbp) // |
    movq    %rsi, -32(%rbp) // |
    movq    $0, -8(%rbp)    // |
    jmp     .L2             // przygotowanie stosu: 0-7: i; 8-23: v[]; 24-31: n;
.L3:    
    movq    -8(%rbp), %rax      // rax = i
    leaq    (%rax,%rax), %rdx   // |
    movq    -24(%rbp), %rax     // |
    addq    %rdx, %rax          // |
    movzwl  (%rax), %eax        // rax = v[i]
    leal    (%rax,%rax), %edx   // rdx = 2*v[i]
    movq    -8(%rbp), %rax      // |
    leaq    (%rax,%rax), %rcx   // |
    movq    -24(%rbp), %rax     // |
    addq    %rcx, %rax          // |
    movw    %dx, (%rax)         // v[i] = rdx -> v[i] = 2*v[i]
    addq    $1, -8(%rbp)        // i++
.L2:    
    movq    -8(%rbp), %rax
    cmpq    -32(%rbp), %rax
    jb      .L3
    nop
    popq    %rbp
    ret
```
Zatem
```
void foo(int16_t v[], size_t n) {
    for (int i = 0; i < n; i++) {
        v[i] = 2*v[i];
    }
}
```
Funkcja mnoży każdy element tablicy przez 2
Stos:
|Dawny stos|
|---|
|rbp|
|i (początkowo 0)|
|?|
|rdi (*v[]) |
|rsi (n) |

## Zad. 6
```
reccur:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp
    movl %edi, -4(%rbp)
    cmpl $0, -4(%rbp)  // |
    jne .L2            // if (x != 0) { jump L2 }
    movl $1, %eax      // |
    jmp .L3            // else return 1
.L2:
    movl -4(%rbp), %eax     // eax = x
    subl $1, %eax           // eax = x-1
    movl %eax, %edi         // |
    call reccur             // |
    imull -4(%rbp), %eax    // return eax*reccur(eax-1)
.L3:
    leave
    ret
```
Zatem
```
int reccur(int x) {
  if (x == 0) {
    return 1;
  }
  return x * reccur(x-1);
}
```
Silnia.

## Zad 7
Minimalna wartość n to 2, ponieważ
```
1 bar: pushq %rbp
2 movq %rsp, %rbp  | wrzucamy wskaźnik stosu do %rbp
3 .....
4 movl 16(%rbp), %eax  | wrzucamy do %raxa zawartość wskaźnika + 16 
5 popq %rbp
6 ret
```
Czyli stos musi wyglądać jakoś tak:
| Stos|
| -------- | 
| Rtn address | 
| %rbp(mówi gdzie jest wskaźnik %rsp) |
| być może coś tu jest ale chodziło o min n | 
| 16(%rbp) |
| 8(%rbp) |
| %rsp |

Zatem wywołanie bar powinno wyglądać tak:
```
pushl a2
pushl a1 
call bar
```
[https://zhu45.org/posts/2017/Jul/30/understanding-how-function-call-works/](https://)
Jak jest więcej argumentów niż się mieści w rejestrach od %rdi, %rsi, %rdx, %rcx, %r8, %r9 to się pozostałe wrzuca na stos
![](https://i.imgur.com/H6it6U8.png)

---



| co | rozmiar | |
| --- | --- | --- |
| ? | ? | 20(%rbp) |
| a7 | 4 | 16(%rbp) |
| Rtn adress | 8 | 8(%rbp) |
| %rbp | 8 | (%rbp) |

wtedy wywołanie bar(1,2,3,4,5,6,7): wygląda następująco:

```

movl $1, %edi
movl $2, %esi
movl $3, %edx
movl $4, %ecx
movl $5, %r8d
movl $6, %r9d
pusl %7
call bar
```