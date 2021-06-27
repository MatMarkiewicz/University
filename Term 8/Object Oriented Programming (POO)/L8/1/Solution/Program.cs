using System;
using System.Linq;
using System.IO;
using System.Net;

namespace Solution
{

    public interface ICommand{
        void Execute(string[] args);
    }

    // a)

    public class FTPReceiver{
        private WebClient _client;

        public FTPReceiver(){
            _client = new WebClient(); 
        }

        public void FTPDownload(string address, string fileName){
            _client.DownloadFile(new Uri(address), fileName);
        }
    }

    public class FTPFileCommand : ICommand{
        private FTPReceiver _receiver;

        public FTPFileCommand(){
            _receiver = new FTPReceiver();
        }

        public void Execute(string[] args){
            _receiver.FTPDownload(args[0], args[1]);
        }
    }

    // b)

    public class HTTPReceiver{
        private WebClient _client;

        public HTTPReceiver(){
            _client = new WebClient(); 
        }

        public void HTTPDownload(string address, string fileName){
            _client.DownloadFile(new Uri(address), fileName);
        }
    }

    public class HTTPFileCommand : ICommand{
        private HTTPReceiver _receiver;

        public HTTPFileCommand(){
            _receiver = new HTTPReceiver();
        }

        public void Execute(string[] args){
            _receiver.HTTPDownload(args[0], args[1]);
        }
    }


    // c)

    public class RandomFileReceiver{
        private static Random _random;

        private static string _RandomString(int length){
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            return new string(Enumerable.Repeat(chars, length)
                .Select(s => s[_random.Next(s.Length)]).ToArray());
        }

        public RandomFileReceiver(){
            _random = new Random();
        }

        public void CreateRandomFile(string fileName){
            using (var fileStream = File.CreateText(fileName)){
                fileStream.Write(_RandomString(100));
            }
        }

    }

    public class RandomFileCommand : ICommand{
        private RandomFileReceiver _receiver;

        public RandomFileCommand(){
            _receiver = new RandomFileReceiver();
        }

        public void Execute(string[] args){
            _receiver.CreateRandomFile(args[0]);
        }

    }

    // d)

    public class CopyFileReceiver{
        public void CopyFile(string source, string destination){
            File.Copy(source, destination);
        }
    }

    public class CopyFileCommand : ICommand{
        private CopyFileReceiver _receiver;

        public CopyFileCommand(){
            _receiver = new CopyFileReceiver();
        }

        public void Execute(string[] args){
            _receiver.CopyFile(args[0], args[1]);
        }
    }

    class Program
    {
        static void Main(string[] args){
            ICommand randomFile = new RandomFileCommand();
            ICommand copyFile = new CopyFileCommand();
            ICommand FTPfile = new FTPFileCommand();
            ICommand HTTPfile = new HTTPFileCommand();
            // randomFile.Execute(new string[]{"random.txt"});
            // copyFile.Execute(new string[]{"random.txt", "random_copy.txt"});
        }
    }
}
