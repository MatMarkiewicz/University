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

        public virtual Plane AcquirePlane(){
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

        public virtual void ReleasePlane(Plane plane){
            if (!_released.Contains(plane)){
                throw new ArgumentException("Incorrect plane.");
            }
            _released.Remove(plane);
            _ready.Add(plane);
        }
    }

    public class TimeProxyAirport : Airport{
        private Airport _airport;

        public TimeProxyAirport(int capacity) : base(capacity){
            _airport = new Airport(capacity);
        }

        private void CheckTime(){
            int time = DateTime.Now.Hour;
            if (time < 8 || time >= 22){
                throw new ArgumentException("The airport is only available between 8 am and 10 pm.");
            }
        }

        public override Plane AcquirePlane(){
            CheckTime();
            return _airport.AcquirePlane();
        }

        public override void ReleasePlane(Plane plane){
            CheckTime();
            _airport.ReleasePlane(plane);
        }
    }

    public class LogProxyAirport : Airport{
        private Airport _airport;

        public LogProxyAirport(int capacity) : base(capacity){
            _airport = new Airport(capacity);
        }

        public override Plane AcquirePlane(){
            Console.WriteLine("{0} - AcquirePlane - ()", DateTime.Now);
            Plane plane = _airport.AcquirePlane();
            Console.WriteLine("{0} - return - ({1})", DateTime.Now, plane);
            return plane;
        }

        public override void ReleasePlane(Plane plane){
            Console.WriteLine("{0} - ReleasePlane - ({1})", DateTime.Now, plane);
            _airport.ReleasePlane(plane);
            Console.WriteLine("{0} - return - ()", DateTime.Now, plane);
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Airport airport = new LogProxyAirport(1);
            Plane plane = airport.AcquirePlane();
            airport.ReleasePlane(plane);
        }
    }
}