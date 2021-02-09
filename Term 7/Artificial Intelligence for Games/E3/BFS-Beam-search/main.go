package main

import (
	"fmt"
	"time"
	"sort"
	"os"
)

type action struct{
	id int
	name string
	value int
	deltas [4]int
} 

type path struct{
	deltas [4]int
	action_count int
	actions []action
	gain int
	used_brews map[action]bool
	used_spells map[action]bool
}

type paths_list []path

var K int = 300
var TURNS_FOR_LEARNING int = 7
var MAX_TURNS_FOR_LEARNING int = 10-TURNS_FOR_LEARNING

func make_action(a action){
	if a.name == "REST"{
		fmt.Println("REST")
	} else{
		fmt.Println(a.name, a.id)
	}
}

func add_deltas(d1, d2 [4]int)(res [4]int){
	for i:=0;i<4;i++{
		res[i] = d1[i]+d2[i]
	}
	return res
}

func int_min(d [4]int)(min int){
	min = d[0]
	for i:=1;i<4;i++{
		if d[i] < min{
			min = d[i]
		}
	}
	return min
}

func min0(a int)(b int){
	if a>0{
		return 0
	}
	return a
}

func int_sum(d [4]int)(sum int){
    for i:=0;i<4;i++{
		sum += d[i]
	}
	return sum
}

func ingredients_bonus(d [4]int)(bon int){
	for i:=1;i<4;i++{
		bon += d[i]
	}
	return bon
}

func (e paths_list) Len() int {
    return len(e)
}

func (e paths_list) Less(i, j int) bool {
	if e[i].gain > e[j].gain{
		return true
	} else if e[i].gain == e[j].gain{
		return ingredients_bonus(e[i].deltas) > ingredients_bonus(e[j].deltas)
	}
	return false
}

func (e paths_list) Swap(i, j int) {
    e[i], e[j] = e[j], e[i]
}

func sort_l(l []path, n int){
	sort.Sort(paths_list(l[:n]))
}

// fmt.Fprintln(os.Stderr, "Debug messages...")

func main() {
	REST_ACTION := action{id:-1, name:"REST", value:-1, deltas: [4]int{-1,-1,-1,-1}}
    for {
        var actionCount int
		fmt.Scan(&actionCount)
		
		BREW_OPTIONS := make([]action, actionCount)
		BREW_COUNT := 0
		CAST_OPTIONS := make([]action, actionCount)
		CAST_COUNT := 0
		LEARN_OPTIONS := make([]action, 42)

        for i := 0; i < actionCount; i++ {
            var actionId int
            var actionType string
            var delta0, delta1, delta2, delta3, price, tomeIndex, taxCount int
            var _castable, _repeatable int
            fmt.Scan(&actionId, &actionType, &delta0, &delta1, &delta2, &delta3, &price, &tomeIndex, &taxCount, &_castable, &_repeatable)
			deltas := [4]int{delta0, delta1, delta2, delta3}

			if actionType == "BREW"{
				BREW_OPTIONS[BREW_COUNT] = action{id:actionId, name:actionType, value:price, deltas:deltas}
				BREW_COUNT++
			} else if actionType == "CAST"{
				CAST_OPTIONS[CAST_COUNT] = action{id:actionId, name:actionType, value:_castable, deltas:deltas}
				CAST_COUNT++
			} else if actionType == "LEARN"{
				LEARN_OPTIONS[tomeIndex] = action{id:actionId, name:actionType, value:taxCount, deltas:deltas}
			}
		}
 
		var inv0, inv1, inv2, inv3, MY_SCORE, OP_SCORE int
		fmt.Scan(&inv0, &inv1, &inv2, &inv3, &MY_SCORE)
		MY_INV := [4]int{inv0, inv1, inv2, inv3}
		fmt.Scan(&inv0, &inv1, &inv2, &inv3, &OP_SCORE)
		// OP_INV := [4]int{inv0, inv1, inv2, inv3}

		// ---------------------------------------------------------------------------------------

		max_time := time.Now().Add(time.Duration(42) * time.Millisecond)

		if TURNS_FOR_LEARNING > 0{
			make_action(LEARN_OPTIONS[0])
			TURNS_FOR_LEARNING--
			continue
		} else if MAX_TURNS_FOR_LEARNING > 0 && LEARN_OPTIONS[0].value > 0{
			make_action(LEARN_OPTIONS[0])
			MAX_TURNS_FOR_LEARNING--
			continue
		}

		possible_paths := make([]path, K*BREW_COUNT*CAST_COUNT+K)
		var possible_paths_count, next_possible_paths_count int

		used_spells := make(map[action]bool)
		for i,spell := range CAST_OPTIONS{
			if i>=CAST_COUNT{
				break
			}
			used_spells[spell] = spell.value==0
		}

		d := MY_INV
		actions := make([]action, 1)
		used_brews := make(map[action]bool)
		possible_paths[0] = path{deltas:d, action_count:0, actions:actions, gain:0, used_brews:used_brews, used_spells:used_spells}
		possible_paths_count = 1

		var iter int
		// fmt.Fprintln(os.Stderr, "Start:", possible_paths[0])

		for{

			next_possible_paths := make([]path, K*BREW_COUNT*CAST_COUNT+K)
			next_possible_paths_count = 0

			if time.Now().After(max_time){
				break
			}

			// if iter<3{
			// 	fmt.Fprintln(os.Stderr, possible_paths_count)
			// 	fmt.Fprintln(os.Stderr, possible_paths[:possible_paths_count])
			// }
			
			// fmt.Fprintln(os.Stderr, "ppc: ", possible_paths_count)
			for i,path_option := range possible_paths{
				if i >= possible_paths_count{
					break
				}
				// fmt.Fprintln(os.Stderr, "PATH: ",i, path_option)

				// Checking brew options
				for j,brew_option := range BREW_OPTIONS{
					if j >= BREW_COUNT{
						break
					}
					deltas_after_action := add_deltas(path_option.deltas, brew_option.deltas)
					if !path_option.used_brews[brew_option] && int_min(deltas_after_action) > -1{
						actions := make([]action, path_option.action_count+1)
						copy(actions, path_option.actions)		
						actions[path_option.action_count] = brew_option
						used_brews := make(map[action]bool)
						for k,v := range path_option.used_brews {
							used_brews[k] = v
						}
						used_brews[brew_option] = true
						next_possible_paths[next_possible_paths_count] = path{deltas:deltas_after_action, action_count: path_option.action_count+1, actions:actions, gain:path_option.gain+brew_option.value, used_brews:used_brews}
						next_possible_paths_count++
					}
				}

				// Checking cast options
				for k,cast_option := range CAST_OPTIONS{
					if k >= CAST_COUNT{
						break
					}
					deltas_after_action := add_deltas(path_option.deltas, cast_option.deltas)
					if !path_option.used_spells[cast_option] && int_min(deltas_after_action) > -1 && int_sum(deltas_after_action) < 11{
						actions := make([]action, path_option.action_count+1)
						copy(actions, path_option.actions)				
						actions[path_option.action_count] = cast_option
						used_spells := make(map[action]bool)
						for k,v := range path_option.used_spells {
							used_spells[k] = v
						}
						used_spells[cast_option] = true
						next_possible_paths[next_possible_paths_count] = path{deltas:deltas_after_action, action_count: path_option.action_count+1, actions:actions, gain:path_option.gain, used_brews:path_option.used_brews, used_spells:used_spells}
						next_possible_paths_count++
					}
				}
				actions := make([]action, path_option.action_count+1)
				copy(actions, path_option.actions)				
				actions[path_option.action_count] = REST_ACTION
				used_spells := make(map[action]bool)
				next_possible_paths[next_possible_paths_count] = path{deltas:path_option.deltas, action_count: path_option.action_count+1, actions:actions, gain:path_option.gain, used_brews:path_option.used_brews, used_spells:used_spells}
				next_possible_paths_count++

			}
			sort_l(next_possible_paths, next_possible_paths_count)
			if next_possible_paths_count > K{
				next_possible_paths_count = K
			}
			possible_paths = next_possible_paths
			possible_paths_count = next_possible_paths_count
			// if iter==0{
			// 	fmt.Fprintln(os.Stderr, "After 1st: ", possible_paths[0])
			// }
			
			iter++
		}
		fmt.Fprintln(os.Stderr, possible_paths[0])
		fmt.Fprintln(os.Stderr, "Iters: ", iter)
		make_action(possible_paths[0].actions[0])

    }
}