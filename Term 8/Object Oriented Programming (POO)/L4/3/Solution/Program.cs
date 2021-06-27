using System;
using System.Collections.Generic;

namespace Solution
{
    public class Plane{}

    public class Airport{
        private int _capacity;
        private List<Plane> _ready = new List<Plane>();
        private List<Plane> _released = new List<Plane>();

        public Airport(int capacity){
            if (capacity <=0 ){
                throw new ArgumentException("Capacity have to be positive.");
            }
            _capacity = capacity;
        }

        public Plane AcquirePlane(){
            if (_released.Count>=_capacity){
                throw new ArgumentException("No more planes avaliable.");
            }
            if (_ready.Count==0){
                _ready.Add(new Plane());
            }

            Plane plane = _ready[0];
            _ready.Remove(plane);
            _released.Add(plane);
            return plane;
        }

        public void ReleasePlane(Plane plane){
            if (!_released.Contains(plane)){
                throw new ArgumentException("Incorrect plane.");
            }
            _released.Remove(plane);
            _ready.Add(plane);
        }


    }
    
    class Program
    {
        static void Main(string[] args)
        {
            Airport airport = new Airport(1);
            Plane plane = airport.AcquirePlane();
        }
    }
}