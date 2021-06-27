using System;
using System.Collections.Generic;

namespace Solution
{

    public interface IShape{
        int GetArea();
    }

    public class Square : IShape{
        private int _a;
        public Square(int a){
            _a = a;
        }
        public int GetArea(){
            return _a * _a;
        }
    }

    public interface IFactoryWorker{
        IShape Create(params object[] parameters);
        bool AcceptParameters(string name, params object[] parameters);
    }

    public class SquareFactoryWorker : IFactoryWorker{
        public IShape Create(params object[] parameters){
            return new Square((int)parameters[0]);
        }

        public bool AcceptParameters(string name, params object[] parameters){
            if (name != "Square"){
                return false;
            } else if (parameters.Length != 1){
                return false;
            }
            return parameters[0] is int;
        }
    }

    public class ShapeFactory{
        private List<IFactoryWorker> _workers = new List<IFactoryWorker>();
        public ShapeFactory(){
            _workers.Add(new SquareFactoryWorker());
        }
        public void RegisterWorker(IFactoryWorker new_worker){
            _workers.Add(new_worker);
        }
        public IShape CreateShape(string name, params object[] parameters){
            foreach (var worker in _workers){
                if (worker.AcceptParameters(name, parameters)){
                    return worker.Create(parameters);
                }
            }
            throw new ArgumentException("No matching shape factory");
        }
    }

    class Program
    {
        public class Rectangle : IShape{
            private int _a;
            private int _b;
            public Rectangle(int a, int b){
                _a = a;
                _b = b;
            }
            public int GetArea(){
                return _a * _b;
            }
        }
        
        public class RectangleFactoryWorker : IFactoryWorker{
            public IShape Create(params object[] parameters){
                return new Rectangle((int)parameters[0], (int)parameters[1]);
            }

            public bool AcceptParameters(string name, params object[] parameters){
                if (name != "Rectangle"){
                    return false;
                } else if (parameters.Length != 2){
                    return false;
                } else if (!(parameters[0] is int)){
                    return false;
                }
                return parameters[1] is int;
            }
        }

        static void Main(string[] args)
        {
            // klient
            ShapeFactory factory = new ShapeFactory();
            IShape square = factory.CreateShape( "Square", 5 );
            Console.WriteLine("Square (5x5) area: {0}", square.GetArea());
            // rozszerzenie
            factory.RegisterWorker( new RectangleFactoryWorker() );
            IShape rect = factory.CreateShape( "Rectangle", 3, 5 );
            Console.WriteLine("Rectangle (3x5) area: {0}", rect.GetArea());
        }
    }
}
