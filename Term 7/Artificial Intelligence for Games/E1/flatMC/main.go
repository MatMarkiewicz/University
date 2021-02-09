// java -jar cg-brutaltester-1.0.0.jar -r "java -Dleague.level=2 -jar tictactoe.jar" -p1 "./flatMC/flatMC.exe" -p2 "./MCTS/MCTS.exe" -t 2 -n 50 -l "./logs/" -s 

package main

import ( 
    "fmt"
    "math/rand"
    "time"
    "os"
)

type pair struct {
    x, y int
}

func simulate(state [9][9]int, last_action pair, last_player int) (final_winner int){
    final_winner = -1

    var main_board = [3][3]int{ {0,0,0}, {0,0,0}, {0,0,0} }
    var f,b bool

    for main_row:=0; main_row<3; main_row++{
        for main_col:=0;main_col<3;main_col++{

            f = true
            b = false
            for i:=0;i<3;i++{

                if (state[3*main_row+i][3*main_col] == state[3*main_row+i][3*main_col+1] && state[3*main_row+i][3*main_col] == state[3*main_row+i][3*main_col+2] && state[3*main_row+i][3*main_col] != 0){
                    main_board[main_row][main_col] = state[3*main_row+i][3*main_col]
                    b = true
                    break
                }

                if (state[3*main_row][3*main_col+i] == state[3*main_row+1][3*main_col+i] && state[3*main_row][3*main_col+i] == state[3*main_row+2][3*main_col+i] && state[3*main_row][3*main_col+i] != 0){
                    main_board[main_row][main_col] = state[3*main_row][3*main_col+i]
                    b = true
                    break
                }
                if !(state[3*main_row+i][3*main_col]!=0 && state[3*main_row+i][3*main_col+1] !=0 && state[3*main_row+i][3*main_col+2]!=0){
                    f = false
                }
            }
            if !b{
                if (state[3*main_row][3*main_col] == state[3*main_row+1][3*main_col+1] && state[3*main_row][3*main_col] == state[3*main_row+2][3*main_col+2] && state[3*main_row][3*main_col]!=0){
                    main_board[main_row][main_col] = state[3*main_row][3*main_col]
                } else if (state[3*main_row][3*main_col+2] == state[3*main_row+1][3*main_col+1] && state[3*main_row][3*main_col+2] == state[3*main_row+2][3*main_col] && state[3*main_row+1][3*main_col+1]!=0){
                    main_board[main_row][main_col] = state[3*main_row+1][3*main_col+1]
                } else if f{
                    main_board[main_row][main_col] = 3
                }
            }

        }
    }

    var actual_player,main_row,main_col,action_index,ones,twos int
    var changed bool
    valid_action_count := 0
    var valid_actions [81]pair
    var action pair

    for {

        if last_player == 2{
            actual_player = 1
        } else {
            actual_player = 2
        }
        main_row = last_action.x/3
        main_col = last_action.y/3
        changed = false

        f = true
        b = false
        for i:=0;i<3;i++{

            if (state[3*main_row+i][3*main_col] == state[3*main_row+i][3*main_col+1] && state[3*main_row+i][3*main_col] == state[3*main_row+i][3*main_col+2] && state[3*main_row+i][3*main_col] != 0){
                main_board[main_row][main_col] = state[3*main_row+i][3*main_col]
                b = true
                changed = true
                break
            }

            if (state[3*main_row][3*main_col+i] == state[3*main_row+1][3*main_col+i] && state[3*main_row][3*main_col+i] == state[3*main_row+2][3*main_col+i] && state[3*main_row][3*main_col+i] != 0){
                main_board[main_row][main_col] = state[3*main_row][3*main_col+i]
                changed = true
                b = true
                break
            }
            if !(state[3*main_row+i][3*main_col]!=0 && state[3*main_row+i][3*main_col+1] !=0 && state[3*main_row+i][3*main_col+2]!=0){
                f = false
            }
        }
        if !b{
            if (state[3*main_row][3*main_col] == state[3*main_row+1][3*main_col+1] && state[3*main_row][3*main_col] == state[3*main_row+2][3*main_col+2] && state[3*main_row][3*main_col]!=0){
                main_board[main_row][main_col] = state[3*main_row][3*main_col]
                changed = true
            } else if (state[3*main_row][3*main_col+2] == state[3*main_row+1][3*main_col+1] && state[3*main_row][3*main_col+2] == state[3*main_row+2][3*main_col] && state[3*main_row+1][3*main_col+1]!=0){
                main_board[main_row][main_col] = state[3*main_row+1][3*main_col+1]
                changed = true
            } else if f{
                main_board[main_row][main_col] = 3
                changed = true
            }
        }

        if changed {
            f = true
            b = false
            ones,twos=0,0
            
            for i := 0;i<3;i++{
                if (main_board[i][0] == main_board[i][1] && main_board[i][0] == main_board[i][2] && main_board[i][0]!=0){
                    final_winner = main_board[i][0]
                    b = true
                    break
                }
                if (main_board[0][i] == main_board[1][i] && main_board[0][i] == main_board[2][i] && main_board[0][i]!=0){
                    final_winner = main_board[0][i]
                    b = true
                    break
                }
                for j:=0;j<3;j++{
                    switch main_board[i][j]{
                        case 0: f=false
                        case 1: ones++
                        case 2: twos++
                    }
                }
            }
            if !b {
                if (main_board[0][0] == main_board[1][1] && main_board[0][0] == main_board[2][2] && main_board[0][0]!=0){
                    final_winner = main_board[0][0]
                } else if (main_board[2][0] == main_board[1][1] && main_board[2][0] == main_board[0][2] && main_board[2][0]!=0){
                    final_winner = main_board[2][0]
                } else if f {
                    if ones>twos{
                        final_winner=1
                    } else if twos>ones{
                        final_winner=2
                    } else{
                        final_winner = 3
                    }
                }
            }

            if final_winner != -1{
                break
            }
        }

        valid_action_count = 0
        if (last_action.x != -1 && main_board[last_action.x%3][last_action.y%3] == 0){
            main_row = last_action.x%3
            main_col = last_action.y%3
            for i:=0;i<3;i++{
                for j:=0;j<3;j++{
                    if state[3*main_row+i][3*main_col+j]==0{
                        valid_actions[valid_action_count] = pair{3*main_row+i,3*main_col+j}
                        valid_action_count++
                    }
                }
            }
        } else {
            for i:=0;i<9;i++{
                for j:=0;j<9;j++{
                    if !(main_board[i/3][j/3]!=0 || state[i][j]!=0){
                        valid_actions[valid_action_count] = pair{i,j}
                        valid_action_count++
                    }
                }
            }
        }

        action_index = rand.Intn(valid_action_count)
        action = valid_actions[action_index]
        state[action.x][action.y] = actual_player

        last_player = actual_player
        last_action = action

    }

    return final_winner
}

func flatMC(valid_actions []pair, valid_actions_counts int, N []int, W []float64, Q []float64, game_state [9][9]int, max_time_ms int)(action pair){
    
    max_time := time.Now().Add(time.Duration(max_time_ms) * time.Millisecond)

    var action_index, winner int

    max_val := 0.0
    max_val_i := 0

    number_of_simulations := 0

    for {
        if time.Now().After(max_time){
            break
        }

        action_index = rand.Intn(valid_actions_counts)
        action = valid_actions[action_index]
        new_game_state := game_state
        new_game_state[action.x][action.y] = 1
        winner = simulate(new_game_state, action, 1)
        N[action_index]++
        number_of_simulations++
        if (winner == 1){
            W[action_index] += 1.0
        } else if (winner == 3){
            W[action_index] += 0.5
        }
    }

    for i:=0;i<valid_actions_counts;i++{
        if (N[i]!=0){
            Q[i] = W[i]/float64(N[i])
        }
        if (Q[i]>max_val){
            max_val = Q[i]
            max_val_i = i
        }
    }

    fmt.Fprintln(os.Stderr, "Number of simulations: ", number_of_simulations)
    return valid_actions[max_val_i]

} 

func main() {

    var actual_state = [9][9]int{ {0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0}}

    var opponentRow, opponentCol int
    fmt.Scan(&opponentRow, &opponentCol)

    if opponentRow!=-1{
        actual_state[opponentRow][opponentCol] = 2
    }
    
    var validActionCount int
    fmt.Scan(&validActionCount)



    var validActions = make([]pair, validActionCount)
    
    for i := 0; i < validActionCount; i++ {
        var row, col int
        fmt.Scan(&row, &col)
        validActions[i] = pair{row,col}
    }

    N := make([]int, validActionCount)
    W := make([]float64, validActionCount)
    Q := make([]float64, validActionCount)
    next_action := flatMC(validActions, validActionCount, N, W, Q, actual_state, 950)
    actual_state[next_action.x][next_action.y] = 1
    fmt.Println(next_action.x, next_action.y)

    for {
        var opponentRow, opponentCol int
        fmt.Scan(&opponentRow, &opponentCol)

        if opponentRow!=-1{
            actual_state[opponentRow][opponentCol] = 2
        }
        
        var validActionCount int
        fmt.Scan(&validActionCount)

        var validActions = make([]pair, validActionCount)
        
        for i := 0; i < validActionCount; i++ {
            var row, col int
            fmt.Scan(&row, &col)
            validActions[i] = pair{row,col}
        }

        N = make([]int, validActionCount)
        W = make([]float64, validActionCount)
        Q = make([]float64, validActionCount)
        next_action := flatMC(validActions, validActionCount, N, W, Q, actual_state, 50)
        actual_state[next_action.x][next_action.y] = 1
        fmt.Println(next_action.x, next_action.y)
    }
}