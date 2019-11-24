import numpy as np
import matplotlib.pyplot as plt
from time import sleep

def live_neighbours(board,i,j):
    N = board.shape[0]
    n = 0
    dx = [-1,0,1,1,1,0,-1,-1]
    dy = [-1,-1,-1,0,1,1,1,0]
    for k in range(8):
        if i+dx[k] >= 0 and i+dx[k] < N and j+dy[k] >= 0 and j+dy[k] < N:
            n += board[i+dx[k],j+dy[k]]
    return n

def looped_live_neighbours(board,i,j):
    N = board.shape[0]
    n = 0
    dx = [-1,0,1,1,1,0,-1,-1]
    dy = [-1,-1,-1,0,1,1,1,0]
    for k in range(8):
            n += board[(i+dx[k])%N,(j+dy[k])%N]
    return n

def game_of_life(n,max_iters = 100,init_p1 = 0.25,looped_edges = False):
    board = np.random.choice(2,(n,n),p=[1-init_p1,init_p1])
    iter_ = max_iters
    t = plt.imshow(board)
    while iter_>0 and np.max(board) > 0:
        new_board = np.copy(board)
        changed = False
        for i in range(n):
            for j in range(n):
                if looped_edges:
                    ln = looped_live_neighbours(board,i,j)
                else:
                    ln = live_neighbours(board,i,j)
                if board[i,j]:
                    if ln != 2 and ln != 3:
                        new_board[i,j] = 0
                        changed = True
                else:
                    if ln == 3:
                        new_board[i,j] = 1
                        changed = True
        if not changed:
            break

        board = new_board

        t.set_data(board)
        plt.draw()
        plt.pause(0.01)
        iter_ -= 1

game_of_life(100,300,0.25,True)
