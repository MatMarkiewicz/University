using System;
using System.Threading;

namespace Solution
{
    public class StandardSingleton{
        private static StandardSingleton _instance = null;
        private static object _lock = new object();

        public static StandardSingleton Instance(){
            if (_instance==null){
                lock (_lock){
                    if (_instance==null){
                        _instance = new StandardSingleton();
                    }
                }
            }
            return _instance;
        }
    }

    public class ThreadSingleton{
        private static ThreadLocal<ThreadSingleton> _instance = new ThreadLocal<ThreadSingleton>();
        private static object _lock = new object();

        public static ThreadSingleton Instance(){
            if (_instance.Value==null){
                lock (_lock){
                    if (_instance.Value==null){
                        _instance.Value = new ThreadSingleton();
                    }
                }
            }
            return _instance.Value;
        }
    }

    public class TimeSingleton{
        private static TimeSingleton _instance = null;
        private static object _lock = new object();
        private static DateTime time;

        public static TimeSingleton Instance(){
            if (_instance==null || (DateTime.Now - time).Seconds >= 5){
                lock (_lock){
                    if (_instance==null || (DateTime.Now - time).Seconds >= 5){
                        _instance = new TimeSingleton();
                        time = DateTime.Now;
                    }
                }
            }
            return _instance;
        }
    }


    class Program
    {
        static void Main(string[] args)
        {
            TimeSingleton s1 = TimeSingleton.Instance();
            TimeSingleton s2 = TimeSingleton.Instance();
            Console.WriteLine(s1==s2);
        }
    }
}
