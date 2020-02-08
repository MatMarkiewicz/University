primes_and_squares = [2, 3, 4, 5, 7, 9, 11, 13, 17, 19, 23, 25, 29, 31, 37, 41, 43, 47, 49]

print('\n'.join(map(str,primes_and_squares)))
res = 0
for p in primes_and_squares:
    inpt_ = input()
    if inpt_ == 'yes':
        res += 1
print('composite' if res > 1 else 'prime')