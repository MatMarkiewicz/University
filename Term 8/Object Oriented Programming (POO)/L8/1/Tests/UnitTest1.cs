using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Linq;
using System.IO;
using System.Net;
using Solution;

namespace Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestRandomFile(){
            ICommand randomFile = new RandomFileCommand();
            randomFile.Execute(new string[]{"test.txt"});

            using (var fileStream = File.OpenText("test.txt")){
                string content = fileStream.ReadToEnd();
                Assert.IsNotNull(content);
                Assert.IsTrue(content.Length==100);
            }
            File.Delete("test.txt");
        }

        [TestMethod]
        public void TestCopyFile(){
            ICommand randomFile = new RandomFileCommand();
            ICommand copyFile = new CopyFileCommand();
            randomFile.Execute(new string[]{"test.txt"});
            copyFile.Execute(new string[]{"test.txt", "test_copy.txt"});

            using (var fileStream = File.OpenText("test.txt")){
                using(var fileStream2 = File.OpenText("test_copy.txt")){
                    string content = fileStream.ReadToEnd();
                    string content2 = fileStream2.ReadToEnd();
                    Assert.AreEqual(content, content2);
                }
            }
            File.Delete("test.txt");
            File.Delete("test_copy.txt");
        }

        [TestMethod]
        public void TestHttpFile(){
            ICommand HTTPfile = new HTTPFileCommand();
            HTTPfile.Execute(new string[]{"https://raw.githubusercontent.com/MatMarkiewicz/KMeans/master/README.md", "test.md"});

            using (var fileStream = File.OpenText("test.md")){
                string content = fileStream.ReadToEnd();
                Assert.IsNotNull(content);
                Assert.IsTrue(content.Length > 0);
            }
            File.Delete("test.md");
        }

        [TestMethod]
        public void TestFtpFile(){
            ICommand FTPfile = new FTPFileCommand();
            FTPfile.Execute(new string[]{"ftp://ftp.freebsd.org/pub/FreeBSD/README.TXT", "test.txt"});

            using (var fileStream = File.OpenText("test.txt")){
                string content = fileStream.ReadToEnd();
                Assert.IsNotNull(content);
                Assert.IsTrue(content.Length > 0);
            }
            File.Delete("test.txt");
        }

    }
}
