using Microsoft.VisualStudio.TestTools.UnitTesting;
using Solution;
using System;

namespace Tests
{
    [TestClass]
    public class UnitTest1
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

        [TestMethod]
        public void TestSquare(){
            ShapeFactory factory = new ShapeFactory();
            IShape square = factory.CreateShape( "Square", 9 );
            Assert.AreEqual(square.GetArea(), 81);
        }

        [TestMethod]
        public void TestRectangle(){
            ShapeFactory factory = new ShapeFactory();
            factory.RegisterWorker( new RectangleFactoryWorker() );
            IShape rect = factory.CreateShape( "Rectangle", 7, 5 );
            Assert.AreEqual(rect.GetArea(), 35);
        }

        [TestMethod]
        public void TestArgumentsParsing(){
            ShapeFactory factory = new ShapeFactory();
            Assert.ThrowsException<ArgumentException>(() => {
                IShape shape = factory.CreateShape( "Square", false );
            });
            
        }

        [TestMethod]
        public void TestArgumentsParsing2(){
            ShapeFactory factory = new ShapeFactory();
            Assert.ThrowsException<ArgumentException>(() => {
                IShape shape = factory.CreateShape( "Circle", 5 );
            });
        }
    }
}
