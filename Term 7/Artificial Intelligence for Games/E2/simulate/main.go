package main

import (
	"fmt"
	"math"
	"math/rand"		
	"time"
)

var MARS_G float64 = -3.711

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
}

type Move struct{
	rotate int
	power int
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
	return &t
}

func (s state) String() string {
	// return fmt.Sprintf("x: %d, y: %d, speed: (%d, %d), fuel: %d, angle: %d, power: %d", s.x, s.y, s.hspeed, s.vspeed, s.fuel, s.rotate, s.power)
	return fmt.Sprintf("x: %d, y: %d, speed: (%d, %d), fuel: %d, angle: %d, power: %d", int(math.Round(s.x)), int(math.Round(s.y)), int(math.Round(s.hspeed)), int(math.Round(s.vspeed)), s.fuel, s.rotate, s.power)
}

func update_state(state *state, move *Move){

	// power update
	if move.power - state.power > 1{
		state.power++
	} else if move.power - state.power < -1{
		state.power--
	} else{
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
	return state.fuel <= 0
}

func crashed(state *state, terrain *Terrain)(b bool){
	if math.Abs(state.hspeed) >= 20.0 || state.vspeed <= -40.0 || state.rotate != 0{
		return true
	}
	return int(math.Round(state.x)) >= terrain.flat_begin && int(math.Round(state.x)) <= terrain.flat_end
}

func calc_goal(state *state, terrain *Terrain)(goal float64){
	if !crashed(state, terrain){
		return float64(state.fuel)
	}

	goal = 0.0
	if state.hspeed < -20.0{
		goal += math.Pow((state.hspeed+20),2)
	} else if state.hspeed > 20.0{
		goal += math.Pow((state.hspeed-20),2)
	}

	if state.vspeed < -40.0{
		goal += math.Pow((state.vspeed+40),2)
	}

	goal += math.Pow(float64(state.rotate)/5,2)

	if state.x < float64(terrain.flat_begin){
		goal += math.Pow((float64(terrain.flat_begin)-state.x)/50.0,2)
	} else if state.x > float64(terrain.flat_end){
		goal += math.Pow((-float64(terrain.flat_end)+state.x)/50.0,2)
	}

	return -goal

}

func simulate(state *state, terrain *Terrain)(goal float64, n int, moves []Move){
	moves = make([]Move, state.fuel)
	for {
		if terminated(state, terrain){
			return calc_goal(state, terrain),n,moves
			break
		}

		move := Move{rotate: rand.Intn(181)-90, power: rand.Intn(5)}
		moves[n] = move
		n++
		update_state(state, &move)
	}
	return calc_goal(state, terrain),n,moves
}


func main() {
	
	land := [7][2]int{{0,100},{1000,500},{1500,1500},{3000,1000},{4000,150},{5500,150},{6999,800}}
	land_ := make([][]int, 7)
	for i:=0;i<7;i++{
		land_[i] = make([]int,2)
		land_[i][0] = land[i][0]
		land_[i][1] = land[i][1]
	}
	terrain := create_terrain(7,land_)

	max_time := time.Now().Add(time.Duration(100) * time.Millisecond)
	n := 0

	for {
		if time.Now().After(max_time){
            break
		}
		act_state := state{x:2500,y:2700,hspeed:0,vspeed:0,fuel:550,rotate:0,power:0}
		_,_,_ = simulate(&act_state, terrain)
		n++
		//fmt.Println(goal)
	}

	fmt.Println(n)

	// fmt.Println(act_state)
	// for i:=0;i<100;i++{
	// 	update_state(&act_state, -90, 1)
	// 	fmt.Println(act_state)
	// }
	// act_state := state{x:5000,y:2500,hspeed:-50,vspeed:0,fuel:1000,rotate:90,power:0}
	// fmt.Println(act_state)
	// update_state(&act_state, -45, 4)
	// fmt.Println(act_state)
	// update_state(&act_state, -45, 4)
	// fmt.Println(act_state)

}