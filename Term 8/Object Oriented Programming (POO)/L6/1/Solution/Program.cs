using System;
using System.IO;

namespace Solution
{

    public interface ILogger{
        void Log( string Message );
    }

    public enum LogType{ None, Console, File }

    public class ConsoleLogger : ILogger{
        public void Log(string Message){
            Console.Write(Message);
        }
    }

    public class FileLogger : ILogger{
        private string _path;

        public FileLogger(string path){
            _path=path;
        }

        public void Log(string Message){
            using (StreamWriter writer = File.AppendText(_path)){
                writer.WriteLine(Message);
            }
        }
    }

    public class NullLogger : ILogger{
        public void Log(string Message){}
    }

    public class LoggerFactory{
        private static LoggerFactory _logger;

        public ILogger GetLogger( LogType LogType, string Parameters = null ){
            switch (LogType){
                case LogType.Console:
                    return new ConsoleLogger();
                case LogType.File:
                    return new FileLogger(Parameters);
                default:
                    return new NullLogger();
            }
        }

        public static LoggerFactory Instance{
            get{
                if (_logger == null){
                    _logger =  new LoggerFactory();
                }
                return _logger;
            }
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            ILogger logger1 = LoggerFactory.Instance.GetLogger( LogType.File, @"./foo.txt" );
            logger1.Log( "foo" ); // logowanie do pliku
            ILogger logger2 = LoggerFactory.Instance.GetLogger( LogType.None );
            logger2.Log( "qux" ); // brak logowania
            ILogger logger3 = LoggerFactory.Instance.GetLogger( LogType.Console );
            logger3.Log( "bar" ); // logowanie do konsoli
        }
    }
}
