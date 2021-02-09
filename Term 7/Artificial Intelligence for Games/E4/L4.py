# Algorithm based on http://www.gameaipro.com/GameAIPro2/GameAIPro2_Chapter14_JPS_Plus_An_Extreme_A_Star_Speed_Optimization_for_Static_Uniform_Cost_Grids.pdf

import sys
import math




J, I = [int(i) for i in input().split()]
walls = [[] for i in range(I)]
for i in range(I):
    for s in input():
        walls[i].append(s=='#')

'''
data format:
[
    0 primary_N bool
    1 primary_E bool
    2 primary_S bool
    3 primary_W bool

    4 dist_N int
    5 dist_NE int
    6 dist_E int
    7 dist_SE int
    8 dist_S int
    9 dist_SW int
    10 dist_W int
    11 dist_NW int
]
'''

dist_map = [[[0 for _ in range(12)] for __ in range(J)] for ___ in range(I)]


# 1. Identify all primary jump points by setting a directional flag in each node

for i in range(I):
    for j in range(J):
        dist_map[i][j][0] = i < I-1 and not walls[i+1][j] and ((j > 0 and walls[i+1][j-1] and not walls[i][j-1]) or (j < J-1 and walls[i+1][j+1] and not walls[i][j+1]))
        dist_map[i][j][1] = j > 0 and not walls[i][j-1] and ((i>0 and walls[i-1][j-1] and not walls[i-1][j]) or (i<I-1 and walls[i+1][j-1] and not walls[i+1][j]))
        dist_map[i][j][2] = i > 0 and not walls[i-1][j] and ((j>0 and walls[i-1][j-1] and not walls[i][j-1]) or (j<J-1 and walls[i-1][j+1] and not walls[i][j+1]))
        dist_map[i][j][3] = j < J-1 and not walls[i][j+1] and ((i < I-1 and walls[i+1][j+1] and not walls[i+1][j]) or (i > 0 and walls[i-1][j+1] and not walls[i-1][j]))


# 2. Mark with distance all westward straight jump points and westward walls by sweeping the map left to right.

for i in range(I):
    c = -1
    jumpPointLastSeen = False
    for j in range(J):
        if walls[i][j]:
            c = -1
            jumpPointLastSeen = False
            dist_map[i][j][10] = 0
            continue
        
        c+=1
        dist_map[i][j][10] = c if jumpPointLastSeen else -c

        if dist_map[i][j][3]:
            c = 0
            jumpPointLastSeen = True


# 3. Mark with distance all eastward straight jump points and eastward walls by sweeping the map right to lef

for i in range(I):
    c = -1
    jumpPointLastSeen = False
    for j in range(J-1,-1,-1):
        if walls[i][j]:
            c = -1
            jumpPointLastSeen = False
            dist_map[i][j][6] = 0
            continue
        
        c+=1
        dist_map[i][j][6] = c if jumpPointLastSeen else -c

        if dist_map[i][j][1]:
            c = 0
            jumpPointLastSeen = True


# 4. Mark with distance all northward straight jump points and northward walls by sweeping the map up to down.

for j in range(J):
    c = -1
    jumpPointLastSeen = False
    for i in range(I):
        if walls[i][j]:
            c = -1
            jumpPointLastSeen = False
            dist_map[i][j][4] = 0
            continue
        
        c+=1
        dist_map[i][j][4] = c if jumpPointLastSeen else -c

        if dist_map[i][j][0]:
            c = 0
            jumpPointLastSeen = True


# 5. Mark with distance all southward straight jump points and southward walls by sweeping the map down to up.

for j in range(J):
    c = -1
    jumpPointLastSeen = False
    for i in range(I-1,-1,-1):
        if walls[i][j]:
            c = -1
            jumpPointLastSeen = False
            dist_map[i][j][8] = 0
            continue
        
        c+=1
        dist_map[i][j][8] = c if jumpPointLastSeen else -c

        if dist_map[i][j][2]:
            c = 0
            jumpPointLastSeen = True


# 6. Mark with distance all southwest/southeast diagonal jump points and southwest/southeast walls by sweeping the map down to up

for i in range(I-1,-1,-1):
    for j in range(J):
        if not walls[i][j]:
            if i==I-1 or j==0 or walls[i+1][j] or walls[i][j-1] or walls[i+1][j-1]:
                pass
            elif not walls[i+1][j] and not walls[i][j-1] and (dist_map[i+1][j-1][8]>0 or dist_map[i+1][j-1][10]>0):
                dist_map[i][j][9] = 1
            else:
                jumpDistance = dist_map[i+1][j-1][9]
                if jumpDistance>0:
                    dist_map[i][j][9] = jumpDistance + 1
                else:
                    dist_map[i][j][9] = jumpDistance - 1

            if i==I-1 or j==J-1 or walls[i+1][j] or walls[i][j+1] or walls[i+1][j+1]:
                pass
            elif not walls[i+1][j] and not walls[i][j+1] and (dist_map[i+1][j+1][8]>0 or dist_map[i+1][j+1][6]>0):
                dist_map[i][j][7] = 1
            else:
                jumpDistance = dist_map[i+1][j+1][7]
                if jumpDistance>0:
                    dist_map[i][j][7] = jumpDistance + 1
                else:
                    dist_map[i][j][7] = jumpDistance - 1


# 7. Mark with distance all northwest/northeast diagonal jump points and northwest/northeast walls by sweeping the map up to down.

for i in range(I):
    for j in range(J):
        if not walls[i][j]:
            if i==0 or j==0 or walls[i-1][j] or walls[i][j-1] or walls[i-1][j-1]:
                pass
            elif not walls[i-1][j] and not walls[i][j-1] and (dist_map[i-1][j-1][4]>0 or dist_map[i-1][j-1][10]>0):
                dist_map[i][j][11] = 1
            else:
                jumpDistance = dist_map[i-1][j-1][11]
                if jumpDistance>0:
                    dist_map[i][j][11] = jumpDistance + 1
                else:
                    dist_map[i][j][11] = jumpDistance - 1

            if i==0 or j==J-1 or walls[i-1][j] or walls[i][j+1] or walls[i-1][j+1]:
                pass
            elif not walls[i-1][j] and not walls[i][j+1] and (dist_map[i-1][j+1][4]>0 or dist_map[i-1][j+1][6]>0):
                dist_map[i][j][5] = 1
            else:
                jumpDistance = dist_map[i-1][j+1][5]
                if jumpDistance>0:
                    dist_map[i][j][5] = jumpDistance + 1
                else:
                    dist_map[i][j][5] = jumpDistance - 1


# output

for i in range(I):
    for j in range(J):
        if not walls[i][j]:
            # flags debug:
            #print(f'{j} {i} {int(dist_map[i][j][0])} 0 {int(dist_map[i][j][1])} 0 {int(dist_map[i][j][2])} 0 {int(dist_map[i][j][3])} 0')
            
            # oputputing the result
            print(f'{j} {i} {" ".join(map(str, dist_map[i][j][4:]))}')