package main

import ( 
    "fmt"
    "math/rand"
    "time"
	"os"
	"math"
)

type pair struct {
    x, y int
}

type MCTS_tree struct {
	actions_count int
	actua_action_index int
	last_action pair
	last_action_i int
	parent *MCTS_tree
	actions []pair
	childrens []*MCTS_tree
	last_player int
	N []int
	totalN int
	W []float64
}

func make_node(actions []pair, n_actions int, parent *MCTS_tree)(tree *MCTS_tree){
	rand.Shuffle(n_actions, func(i, j int) { actions[i], actions[j] = actions[j], actions[i] })
	new_tree := MCTS_tree{actions:actions, parent:parent}
	new_tree.actions_count = n_actions
	new_tree.actua_action_index = 0
	new_tree.N = make([]int, len(actions))
	new_tree.totalN = 0
	new_tree.W = make([]float64, len(actions))
	new_tree.childrens = make([]*MCTS_tree, len(actions))
	new_tree.last_action = pair{-1,-1}
	new_tree.last_player = 1
	new_tree.last_action_i = -1
	return &new_tree
}

func get_valid_actions(v *MCTS_tree, org_state [9][9]int, last_action pair)(valid_actions []pair, valid_action_count int){
	state := org_state
	valid_actions = make([]pair, 81)
	state[last_action.x][last_action.y] = 3-v.last_player
	for {
		if v.parent == nil{
			break
		}
		state[v.last_action.x][v.last_action.y] = v.last_player
		v = v.parent
	}

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
	
	valid_action_count = 0
    var main_row,main_col int
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

	return valid_actions,valid_action_count



}

func choose_node(root *MCTS_tree, state [9][9]int)(res *MCTS_tree){
	C := 1.0
	if root == nil{
		return root
	}
	for {
		if root.actions_count == 0{
			return root
		}
		if root.actua_action_index != root.actions_count {
			action := root.actions[root.actua_action_index]

			valid_actions,n := get_valid_actions(root, state, action)
			new_tree := make_node(valid_actions, n, root)
			new_tree.last_action = action
			root.childrens[root.actua_action_index] = new_tree
			new_tree.last_player = 3-root.last_player
			new_tree.last_action_i = root.actua_action_index
			root.actua_action_index++
			return new_tree
		} else {
			best_val := 0.0
			best_val_i := 0
			for i:=0;i<root.actions_count;i++{
				Q := root.W[i]/float64(root.N[i]) + C*math.Sqrt(2*math.Log(float64(root.totalN))/float64(root.N[i]))
				if Q>best_val {
					best_val=Q
					best_val_i = i
				}
			}
			root = root.childrens[best_val_i]
		}
	}
}

func simulate(org_state [9][9]int, v *MCTS_tree) (final_winner int){
	final_winner = -1
	
	state := org_state

	for {
		if v.parent == nil{
			break
		}
		state[v.last_action.x][v.last_action.y] = v.last_player
		v = v.parent
	}

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

    last_player := v.last_player
    last_action := v.last_action

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

func backprop(v *MCTS_tree, final_winner int){
	win_reward := 1.0
	draw_reward := 0.0
	lose_reward := 1-win_reward
    if v ==nil{
		return
	}
    last_action_i := v.last_action_i
    v = v.parent
	for {
		if v ==nil{
			break
		}
        v.totalN++
        v.N[last_action_i]++
        if final_winner == v.last_player{
            v.W[last_action_i] = v.W[last_action_i] + lose_reward
        } else if final_winner == 0{
            v.W[last_action_i] = v.W[last_action_i] + draw_reward
        } else {
            v.W[last_action_i] = v.W[last_action_i] + win_reward
        }
        last_action_i = v.last_action_i
        v = v.parent
    }
}

func MCTS(root *MCTS_tree, max_time_ms int, org_state [9][9]int)(action pair){
	max_time := time.Now().Add(time.Duration(max_time_ms) * time.Millisecond)

	var act_node *MCTS_tree
	var winner_of_simulation int
	for {
		if time.Now().After(max_time){
            break
		}

		act_node = choose_node(root, org_state)
		winner_of_simulation = simulate(org_state, act_node)
		backprop(act_node, winner_of_simulation)
	}

	fmt.Fprintln(os.Stderr, "Number of simulations: ", root.totalN)

	max_n := 0
	max_n_i := 0

	for i:=0;i<root.actions_count;i++{
		if root.N[i] > max_n{
			max_n = root.N[i]
			max_n_i = i
		}
	}

	return root.actions[max_n_i]

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

	root := make_node(validActions,validActionCount,nil)
	root.last_action = pair{opponentRow,opponentCol}
	root.last_player = 2
	action := MCTS(root,950,actual_state)
	actual_state[action.x][action.y] = 1
	fmt.Println(action.x, action.y)

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

		for i:=0;i<root.actions_count;i++{
			if root.actions[i].x == action.x && root.actions[i].y == action.y{
				root = root.childrens[i]
				break
			}
		}
        if root == nil{
            root = make_node(validActions,validActionCount,nil)
            root.last_action = pair{opponentRow,opponentCol}
            root.last_player = 2
        } else {
            for i:=0;i<root.actions_count;i++{
                if root.actions[i].x == opponentRow && root.actions[i].y == opponentCol{
                    root = root.childrens[i]
                    break
                }
		    }
            if root == nil{
                root = make_node(validActions,validActionCount,nil)
                root.last_action = pair{opponentRow,opponentCol}
                root.last_player = 2
            }
        }

		root.parent = nil
		action = MCTS(root,50,actual_state)
		actual_state[action.x][action.y] = 1
		fmt.Println(action.x, action.y)

    }
}