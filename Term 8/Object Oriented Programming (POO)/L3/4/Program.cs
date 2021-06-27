using System;

/*
Pierwotna wersja kodu w kontekście załączonego kodu klienckiego nie spełniała zasady LSP.
Podklasa "kwadrat" ograniczała możliwości ustawienia wartości Height oraz Width.

Zmodyfikowałem kod dodając klasę abstrakcyjną "Rectangular", która nie zakłada nic
o sposobie ustawiania wartości Height oraz Width.
Klasa Rectangle posiada konstruktor przyjmujący 2 argumenty,
klasa Square posiada konstruktor przyjmujący 1 argument,
obie klasy pozwalają na odczytanie wartości Height oraz Width.
*/

namespace _4
{
    class Program
    {
        static void Main(string[] args)
        {
            AreaCalculator calc = new AreaCalculator();

            int w = 4, h = 5;
            Rectangular r = new Rectangle(w, h);
            Console.WriteLine("Prostokąt o wymiarach {0} na {1} ma pole {2}.", w, h, calc.CalculateArea(r));

            Rectangular s = new Square(w);
            Console.WriteLine("Kwadrat o wymiarach {0} na {1} ma pole {2}.", w, w, calc.CalculateArea(s));
        }
    }
    public abstract class Rectangular{
        public abstract int Width{get;}
        public abstract int Height{get;}
    }
    public class Rectangle : Rectangular{
        public Rectangle(int w, int h){
            this.Width = w;
            this.Height = h;
        }
        public override int Width{get;}
        public override int Height{get;}
    }
    public class Square : Rectangular{
        public Square(int w){
            this.Width = w;
            this.Height = w;
        }
        public override int Width{get;}
        public override int Height{get;}
    }
    public class AreaCalculator{
        public int CalculateArea( Rectangular rect ){
            return rect.Width * rect.Height;
        }
    }

}
