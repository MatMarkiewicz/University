package main

import (
	"fmt"
	"math"
	"math/rand"		
	"sort"
	"time"
	"os"
)

var MARS_G float64 = -3.711
var POPULATION_SIZE int = 200
var GEN_LEN int = 75
var MAX_TIME int = 90
var ANGLE_RES int = 15
var SIMULATION_PER_INDIVIDUAL int = 20
var CROSSOVER_PROB float64 = 1.0
var MUTATE_PROB float64 = 0.1
var LOCAL_SEARCH_PROB float64 = 0.0
var KEEP_K_BEST int = 20
var EVALUATE_K int = 5

type state struct{
	x float64
	y float64
	hspeed float64
	vspeed float64
	fuel int
	rotate int
	power int
}

type Terrain struct{
	surface [7000]float64
	flat_begin int
	flat_end int
	max_x_err float64
	max_y_err float64
	initial_fuel int
}

type Move struct{
	rotate int
	power int
}

func (s state) String() string {
	// return fmt.Sprintf("x: %d, y: %d, speed: (%d, %d), fuel: %d, angle: %d, power: %d", s.x, s.y, s.hspeed, s.vspeed, s.fuel, s.rotate, s.power)
	return fmt.Sprintf("x: %d, y: %d, speed: (%d, %d), fuel: %d, angle: %d, power: %d", int(math.Round(s.x)), int(math.Round(s.y)), int(math.Round(s.hspeed)), int(math.Round(s.vspeed)), s.fuel, s.rotate, s.power)
}

// ===========================================================================================
type argsort struct {
	s    []float64 // Points to orignal array but does NOT alter it.
	inds []int     // Indexes to be returned.
}

func (a argsort) Len() int {
	return len(a.s)
}

func (a argsort) Less(i, j int) bool {
	return a.s[a.inds[i]] < a.s[a.inds[j]]
}

func (a argsort) Swap(i, j int) {
	a.inds[i], a.inds[j] = a.inds[j], a.inds[i]
}

// ArgsortNew allocates and returns an array of indexes into the source float
// array.
func ArgsortNew(src []float64) []int {
	inds := make([]int, len(src))
	for i := range src {
		inds[i] = i
	}
	Argsort(src, inds)
	return inds
}

// Argsort alters a caller-allocated array of indexes into the source float
// array. The indexes must already have values 0...n-1.
func Argsort(src []float64, inds []int) {
	if len(src) != len(inds) {
		panic("floats: length of inds does not match length of slice")
	}
	a := argsort{s: src, inds: inds}
	sort.Sort(a)
}
// =======================================================================================


func update_state(state *state, move *Move){

	// power update
	if move.power - state.power > 1{
		state.power++
	} else if move.power - state.power < -1{
		state.power--
	} else if state.fuel < move.power{
		state.power = state.fuel
	} else {
		state.power = move.power
	}

	// angle update
	if move.rotate - state.rotate > 15{
		state.rotate += 15
	} else if move.rotate - state.rotate < -15{
		state.rotate -= 15
	} else {
		state.rotate = move.rotate
	}

	// update fuel
	state.fuel -= state.power

	// update speed and position
	ah := float64(state.power) * -math.Sin(float64(state.rotate)*math.Pi/180.0)
	av := float64(state.power) * math.Cos(float64(state.rotate)*math.Pi/180.0) + MARS_G
	state.x += state.hspeed + ah*0.5
	state.y += state.vspeed + av*0.5
	state.hspeed += ah
	state.vspeed += av
}

func terminated(state *state, terrain *Terrain)(b bool){
	if state.x < -0.5 || state.x > 6999.5 || state.y <= terrain.surface[int(math.Round(state.x))] || state.y > 2999.5{
		return true
	}
	return false
}

func crashed(prev_state *state, state *state, terrain *Terrain)(b bool){
    if math.Abs(prev_state.hspeed) >= 20.0 || prev_state.vspeed <= -40.0 || prev_state.rotate != 0{
		return true
	}
    if int(math.Round(prev_state.x)) <= terrain.flat_begin || int(math.Round(prev_state.x)) >= terrain.flat_end{
        return true
    }
	if math.Abs(state.hspeed) >= 20.0 || state.vspeed <= -40.0 || state.rotate != 0{
		return true
	}
	return int(math.Round(state.x)) <= terrain.flat_begin || int(math.Round(state.x)) >= terrain.flat_end
}

// func state_rate(state *state, terrain *Terrain)(hspeed_err, vspeed_err, rotate_err, x_err, y_err float64){
// 	if math.Abs(state.hspeed) > 15.0{
// 		hspeed_err = (math.Abs(state.hspeed)-15.0)/100.0
// 	}

// 	if math.Abs(state.vspeed) > 20.0{
// 		vspeed_err = (math.Abs(state.vspeed)-20.0)/100.0
// 	}

// 	rotate_err = math.Abs(float64(state.rotate))/90.0

// 	if state.x < float64(terrain.flat_begin+100){
// 		x_err = math.Abs((float64(terrain.flat_begin+100)-state.x))/terrain.max_x_err
// 	} else if state.x > float64(terrain.flat_end-100){
// 		x_err = math.Abs((-float64(terrain.flat_end-100)+state.x))/terrain.max_x_err
// 	}

// 	y_err = math.Abs(terrain.surface[int(math.Round(math.Max(0.0, state.x)))]-state.y)/terrain.max_y_err
// 	return hspeed_err, vspeed_err, rotate_err, x_err, y_err
// }

func state_rate(state *state, terrain *Terrain)(hspeed_err, vspeed_err, rotate_err, x_err, y_err float64){
	if math.Abs(state.hspeed) > 20.0{
		hspeed_err = (math.Abs(state.hspeed)-20.0)/100.0
	}

	if math.Abs(state.vspeed) > 40.0{
		vspeed_err = (math.Abs(state.vspeed)-40.0)/100.0
	}

	rotate_err = math.Abs(float64(state.rotate))/90.0

	if state.x < float64(terrain.flat_begin+100){
		x_err = math.Abs((float64(terrain.flat_begin+100)-state.x))/terrain.max_x_err
	} else if state.x > float64(terrain.flat_end-100){
		x_err = math.Abs((-float64(terrain.flat_end-100)+state.x))/terrain.max_x_err
	}

	y_err = math.Abs(terrain.surface[int(math.Round(math.Max(0.0, state.x)))]-state.y)/terrain.max_y_err
	return hspeed_err, vspeed_err, rotate_err, x_err, y_err
}

func calc_goal(prev_state *state, state *state, terrain *Terrain)(goal float64){
	if terminated(state, terrain) && !crashed(prev_state, state, terrain){
		return float64(state.fuel)/float64(terrain.initial_fuel)
	}

	hspeed_err, vspeed_err, rotate_err, x_err, _ := state_rate(state, terrain)
    // if x_err > 0.0{
    //     if hspeed_err > 0.1{
    //         goal += hspeed_err
    //     }
    //     if vspeed_err > 0.2{
    //         goal += vspeed_err
    //     }
    //     return -0.5 -x_err
    // }
    return -(2.0*x_err + 0.15*hspeed_err + 0.75*vspeed_err + 0.35*rotate_err)
}

// func simulate(state *state, terrain *Terrain)(goal float64, n int, moves []Move){
// 	moves = make([]Move, state.fuel)
// 	for {
// 		if terminated(state, terrain){
// 			return calc_goal(state, terrain),n,moves
// 			break
// 		}

// 		move := Move{rotate: rand.Intn(181)-90, power: rand.Intn(5)}
// 		moves[n] = move
// 		n++
// 		update_state(state, &move)
// 	}
// 	return calc_goal(state, terrain),n,moves
// }

func random_move(last_move *Move)(new_move *Move){
	var angle, power, power_dif, angle_dif int
	power_dif = rand.Intn(3)-1
	angle_dif = rand.Intn(30/ANGLE_RES+1)*ANGLE_RES - 15
	power = (last_move.power + power_dif)
	if power<0{
		power = 0
	} else if power>4 {
		power = 4
	}
	angle = (last_move.rotate + angle_dif)
	if angle < -90{
		angle = -90
	} else if angle>90 {
		angle = 90
	}
	move := Move{rotate: angle, power:power}
	return &move
}

func apply_moves(root_state *state, terrain *Terrain, moves []Move, n_moves int)(last_stat *state, new_state *state){
    state := *root_state
    last_state := *root_state
	for i:=0;i<n_moves;i++{
        last_state = state
		update_state(&state, &moves[i])
		if terminated(&state, terrain){
			break
		}
	}
    return &last_state, &state
}

func simulate(root_state *state, terrain *Terrain, moves []Move, n_moves int)(goal float64){
	state := *root_state
    last_state := *root_state
    // weights := [5]float64{0.2, 0.2, 0.2, 0.2, 0.2}
	for i:=0;i<n_moves;i++{
        last_state = state
		update_state(&state, &moves[i])
		if terminated(&state, terrain){
			return calc_goal(&last_state, &state, terrain)
		}
	}
	last_move := moves[n_moves-1]
	var move *Move
	for {
		move = random_move(&last_move)
        last_state = state
		update_state(&state, move)
		if terminated(&state, terrain){
			return calc_goal(&last_state, &state, terrain)
		}
		last_move = *move
	}
	return calc_goal(&last_state, &state, terrain)
}

func initialize_population(pop [][]Move){
	var angle, power int
	for i:=0;i<POPULATION_SIZE;i++{
		power = rand.Intn(5)
		angle = rand.Intn(180/ANGLE_RES+1)*ANGLE_RES - 90
		move := Move{rotate: angle, power:power}
		pop[i][0] = move
		for j:=1;j<GEN_LEN;j++{
			pop[i][j] = *random_move(&pop[i][j-1])
		}
	}
}

func roll_horizon(pop [][]Move){
	for i:=0;i<POPULATION_SIZE;i++{
		for j:=0;j<GEN_LEN-1;j++{
			pop[i][j] = pop[i][j+1]
		}
		pop[i][GEN_LEN-1] = *random_move(&pop[i][GEN_LEN-2])
	}
}


func evaluate_population(state *state, terrain *Terrain, pop [][]Move)(res []float64){
	res = make([]float64, len(pop))
	
	for i:=0;i<len(pop);i++{
		
        // total_goal := 0.0
		// for k:=0;k<SIMULATION_PER_INDIVIDUAL;k++{
		// 	total_goal += simulate(state, terrain, pop[i], GEN_LEN)
		// }
		// res[i] = total_goal/float64(SIMULATION_PER_INDIVIDUAL)
        prev_temp_state, temp_state := apply_moves(state, terrain, pop[i], GEN_LEN)
        // temp_k_state := apply_moves(state, terrain, pop[i][:EVALUATE_K], EVALUATE_K)
        // var weights [5]float64
        // if math.Abs(terrain.surface[int(math.Round(math.Max(0.0, state.x)))]-state.y) < 50.0{
        //     weights = [5]float64{0.05, 0.05, 0.8, 0.05, 0.05}
        // } else if math.Abs(terrain.surface[int(math.Round(math.Max(0.0, state.x)))]-state.y) < 700.0 && state.x > float64(terrain.flat_begin) && state.x < float64(terrain.flat_end) {
        //     weights = [5]float64{0.035, 0.9, 0.035, 0.015, 0.015}
        // } else {
        //     weights = [5]float64{0.05, 0.5, 0.01, 0.4, 0.04}
        // }
        
        // res[i] = calc_goal(temp_state, terrain, weights)

        // res[i] = (calc_goal(temp_state, terrain, weights)+calc_goal(temp_k_state, terrain, weights))/2.0
        res[i] = calc_goal(prev_temp_state, temp_state, terrain)
	}

	return res
}
func create_terrain(n int, land_infos [][]int)(terrain *Terrain){
	last_x, last_y := land_infos[0][0], land_infos[0][1]
	j := 1
	next_x,next_y := land_infos[j][0], land_infos[j][1]

	t := Terrain{}

	if last_y == next_y{
		t.flat_begin,t.flat_end = last_x,next_x
	}
		

	for i:=0;i<7000;i++{
		t.surface[i] = float64(last_y) + (float64(next_y-last_y)/float64(next_x-last_x))*float64(i-last_x)
		if i==next_x && i!=6999{
			last_x, last_y = next_x, next_y
			j++
			next_x,next_y = land_infos[j][0], land_infos[j][1]

			if last_y == next_y{
				t.flat_begin,t.flat_end = last_x,next_x
			}

		}
	}

	if t.flat_begin > 6999-t.flat_end{
		t.max_x_err = math.Abs(float64(t.flat_begin))
	} else {
		t.max_x_err = math.Abs(6999.0-float64(t.flat_end))
	}

	t.max_y_err = math.Abs(2999.0-t.surface[t.flat_end])

	return &t
}

func intmax(a int, b int)(res int){
	if a>b{
		return a
	} 
	return b
}

func intmin(a int, b int)(res int){
	if a<b{
		return a
	} 
	return b
}

func mutate(state *state, terrain *Terrain, pop [][]Move){

	for i:=0;i<POPULATION_SIZE;i++{
        for j:=0;j<GEN_LEN;j++{
            if rand.Float64() < MUTATE_PROB{
			    pop[i][j] = *random_move(&pop[i][j])
		    }
        }

		if rand.Float64() < LOCAL_SEARCH_PROB{
			local_search_pop := make([][]Move, 4*EVALUATE_K)
			for i:=0;i< 4*EVALUATE_K;i++{
				local_search_pop[i] = make([]Move ,GEN_LEN)
			}
			for j:=0;j<EVALUATE_K;j++{
				for k:=0;k<4;k++{
					new_ind := pop[i]
					new_move := pop[i][j]
					switch k{
					case 0:
						new_move.rotate = intmin(new_move.rotate+ANGLE_RES, 90)
					case 1:
						new_move.rotate = intmax(new_move.rotate-ANGLE_RES, -90)
					case 2:
						new_move.power = intmin(new_move.power+1,4)
					case 3:
						new_move.power = intmax(new_move.power-1,0)
					}
					new_ind[j] = new_move
					local_search_pop[4*j+k] = new_ind
				}
			}
			scores := evaluate_population(state, terrain, local_search_pop)
			sorted_indexes := ArgsortNew(scores)
			pop[i] = local_search_pop[sorted_indexes[0]]
		}
	}
}

func uniform_crossover(p1 []Move, p2 []Move)(c1 []Move, c2 []Move){
	c1 = make([]Move, GEN_LEN)
	c2 = make([]Move, GEN_LEN)
	for i:=0;i<GEN_LEN;i++{
		if rand.Float64() < 0.5{
			c1[i], c2[i] = p1[i], p2[i]
		} else{
			c1[i], c2[i] = p2[i], p1[i]
		}
	}
	return c1, c2
}

func continuous_crossover(p1 []Move, p2 []Move)(c1 []Move, c2 []Move){
	c1 = make([]Move, GEN_LEN)
	c2 = make([]Move, GEN_LEN)
    var r float64
    var angle int
	for i:=0;i<GEN_LEN;i++{
        r = rand.Float64()
        angle = int((1.0-r)*float64(p1[i].rotate) + r*float64(p2[i].rotate))
        angle -= angle%ANGLE_RES
        if angle < -90{
            angle = -90
        }
        c1[i] = Move{rotate: angle, power: int((1.0-r)*float64(p1[i].power) + r*float64(p2[i].power))}
        c2[i] = Move{rotate: p1[i].rotate+p2[i].rotate-angle, power: int((1.0-r)*float64(p2[i].power) + r*float64(p1[i].power))}
	}
    // fmt.Fprintln(os.Stderr, "p1 ", p1)
    // fmt.Fprintln(os.Stderr, "p2 ", p2)
    // fmt.Fprintln(os.Stderr, "c1 ", c1)
    // fmt.Fprintln(os.Stderr, "c2 ", c2)
    // fmt.Fprintln(os.Stderr, "")
	return c1, c2
}

func n_point_crossover(p1 []Move, p2 []Move, n int)(c1 []Move, c2 []Move){
	c1 = make([]Move, GEN_LEN)
	c2 = make([]Move, GEN_LEN)
	points := make([]int, n+1)
	for i:=0;i<n;i++{
		points[i] = rand.Intn(GEN_LEN)
	}
	points[n] = GEN_LEN
	sort.Ints(points)
	order := false
	act_i := 0
	for i:=0;i<GEN_LEN;i++{
		if i==points[act_i]{
			order = !order
			act_i++
		}
		if order {
			c1[i], c2[i] = p1[i], p2[i]
		} else{
			c1[i], c2[i] = p2[i], p1[i]
		}
	}
	return c1, c2
}

// func crossover_population(state *state, terrain *Terrain, pop [][]Move)(new_pop [][]Move){
// 	child_pop := pop
// 	for i:=0;i<POPULATION_SIZE/2;i++{
// 		if rand.Float64() < CROSSOVER_PROB{
// 			child_pop[2*i], child_pop[2*i+1] = continuous_crossover(child_pop[2*i], child_pop[2*i+1])
// 		}
// 	}
// 	scores := evaluate_population(state, terrain, child_pop)
// 	child_pop = sort_population(child_pop, scores)
// 	for i:=POPULATION_SIZE-KEEP_K_BEST;i<POPULATION_SIZE;i++{
// 		child_pop[i] = pop[POPULATION_SIZE-i]
// 	}
// 	return child_pop
// }

func crossover_population(state *state, terrain *Terrain, pop [][]Move, scores []float64)(new_pop [][]Move){
	child_pop := make([][]Move, POPULATION_SIZE)
    sorted_indexes := ArgsortNew(scores)
    for i, j := 0, POPULATION_SIZE-1; i < j; i, j = i+1, j-1 {
        sorted_indexes[i], sorted_indexes[j] = sorted_indexes[j], sorted_indexes[i]
    }
    // fmt.Fprintln(os.Stderr, "scores ", sorted_indexes)
    sums := make([]float64, POPULATION_SIZE)
    var sum,r float64
    for i:=0;i<POPULATION_SIZE;i++{
        sum += scores[i]
    }
    sums[0] = scores[sorted_indexes[0]]/sum
    for i:=1;i<POPULATION_SIZE;i++{
        sums[i] = sums[i-1] + scores[sorted_indexes[i]]/sum
    }

    for i:=0;i<KEEP_K_BEST;i++{
        child_pop[i] = pop[sorted_indexes[i]]
    }

    for i:=KEEP_K_BEST;i<POPULATION_SIZE;i++{
        r = rand.Float64()
        j := 0
        for {
            if j==POPULATION_SIZE-1 || r > sums[j]{
                child_pop[i] = pop[sorted_indexes[j]]
                break
            }
            j++
        }
        if i>KEEP_K_BEST && i%2==1{
            child_pop[i], child_pop[i-1] = continuous_crossover(child_pop[i], child_pop[i-1])
        }
    }

	return child_pop
}

func sort_population(pop [][]Move, res []float64)(new_pop [][]Move){
	sorted_indexes := ArgsortNew(res)
	new_pop = make([][]Move, POPULATION_SIZE)
	for i:=0;i<POPULATION_SIZE;i++{
		new_pop[i] = pop[sorted_indexes[POPULATION_SIZE-1-i]]
	}
	return new_pop
}

func min_mean_max_score(res []float64)(min, mean, max float64){
	min = 10.0
    max = -10.0
    i := 0
	for _, value := range res{
		if max < value{
			max = value
		} else if min > value{
            min = value
        }
        mean += value
        i++
	}
    mean /= float64(i)
	return min, mean, max
}

func make_evolution(state *state, terrain *Terrain, pop [][]Move)(new_pop [][]Move, max_s float64){
	max_time := time.Now().Add(time.Duration(MAX_TIME) * time.Millisecond)
	iters := 0
    var min_s, mean_s float64

	for {
		scores := evaluate_population(state, terrain, pop)
		// pop = sort_population(pop, scores)
        // fmt.Fprintln(os.Stderr, "Pop ", pop)
        // fmt.Fprintln(os.Stderr, "scores ", scores)
		if time.Now().After(max_time){
			min_s, mean_s, max_s = min_mean_max_score(scores)
            break
		}
		pop = crossover_population(state, terrain, pop, scores)
        // fmt.Fprintln(os.Stderr, "Pop_cv ", pop)
        // fmt.Fprintln(os.Stderr, "")
		mutate(state, terrain, pop)
		iters++
        
	}
	fmt.Fprintln(os.Stderr, "Number of iterations: ", iters, "min, mean, max: ", min_s, mean_s, max_s)
    hspeed_err, vspeed_err, rotate_err, x_err, y_err := state_rate(state, terrain)
    fmt.Fprintln(os.Stderr, *state)
    fmt.Fprintln(os.Stderr, hspeed_err, vspeed_err, rotate_err, x_err, y_err)
	return pop, max_s
}

func main() {

	rand.Seed(time.Now().UTC().UnixNano())

	var N, last_x, last_y, next_x, next_y int
	fmt.Scan(&N)
	fmt.Scan(&last_x, &last_y)
	fmt.Scan(&next_x, &next_y)

	t := Terrain{}

	if last_y == next_y{
		t.flat_begin,t.flat_end = last_x,next_x
	}

	for i:=0;i<7000;i++{
		t.surface[i] = float64(last_y) + (float64(next_y-last_y)/float64(next_x-last_x))*float64(i-last_x)
		if i==next_x && i!=6999{
			last_x, last_y = next_x, next_y
			fmt.Scan(&next_x, &next_y)
			if last_y == next_y{
				t.flat_begin, t.flat_end = last_x, next_x
			}
		}
	}

	if t.flat_begin > 6999-t.flat_end{
		t.max_x_err = math.Abs(float64(t.flat_begin))
	} else {
		t.max_x_err = math.Abs(6999.0-float64(t.flat_end))
	}

	t.max_y_err = math.Abs(2999.0-t.surface[t.flat_end])

	POPULATION := make([][]Move, POPULATION_SIZE)
	for i:=0;i<POPULATION_SIZE;i++{
		POPULATION[i] = make([]Move ,GEN_LEN)
	}
	initialize_population(POPULATION)

	var X, Y, HS, VS, F, R, P int
	fmt.Scan(&X, &Y, &HS, &VS, &F, &R, &P)
	state := state{x:float64(X),y:float64(Y),hspeed:float64(HS),vspeed:float64(VS),fuel:F,rotate:R,power:P}
	

	// land := [7][2]int{{0,100},{1000,500},{1500,1500},{3000,1000},{4000,150},{5500,150},{6999,800}}
	// land_ := make([][]int, 7)
	// for i:=0;i<7;i++{
	// 	land_[i] = make([]int,2)
	// 	land_[i][0] = land[i][0]
	// 	land_[i][1] = land[i][1]
	// }
	// t := create_terrain(7,land_)
	// state := state{x:2500,y:2700,hspeed:0,vspeed:0,fuel:550,rotate:0,power:0}

	t.initial_fuel = F

	var next_move Move

	for {
		POPULATION, _ = make_evolution(&state, &t, POPULATION)
		next_move = POPULATION[0][0]
		update_state(&state, &next_move)
		
        if next_move.rotate > 90{
            next_move.rotate = 90
        } else if next_move.rotate < -90{
            next_move.rotate = -90
        }
		fmt.Println(next_move.rotate, next_move.power)
		fmt.Scan(&X, &Y, &HS, &VS, &F, &R, &P)
		roll_horizon(POPULATION)

	}

	

	// fmt.Println(POPULATION)
	// fmt.Println("===========================================")
	// scores := evaluate_population(&state, t, POPULATION)
	// fmt.Println(scores)
	// fmt.Println("===========================================")
	// POPULATION = sort_population(POPULATION, scores)
	// fmt.Println(POPULATION)
	// fmt.Println("===========================================")
	// crossover_population(POPULATION)
	// fmt.Println(POPULATION)
	// fmt.Println("===========================================")
	// mutate(POPULATION)
	// fmt.Println(POPULATION)
	// fmt.Println("===========================================")



	// max_time := time.Now().Add(time.Duration(MAX_TIME) * time.Millisecond)
	// n := 0
	// for {
	// 	if time.Now().After(max_time){
    //         break
	// 	}
	// 	act_state := state{x:2500,y:2700,hspeed:0,vspeed:0,fuel:550,rotate:0,power:0}
	// 	_,_,_ = simulate(&act_state, &t)
	// 	n++
	// 	//fmt.Println(goal)
	// }
	// fmt.Println(n)

}