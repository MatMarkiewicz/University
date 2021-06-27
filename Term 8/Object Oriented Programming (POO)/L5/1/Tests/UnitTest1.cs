using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using netDumbster.smtp;
using Solution;

namespace Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestSend(){
            string host = "localhost";
            int port = 12345;
            string from = "TestFrom@gmail.com";
            string to = "TestTo@gmail.com";
            string subject = "TestSubject";
            string body = "TestBody";
            var server = SimpleSmtpServer.Start(port);

            SmtpFacade smtpFacade = new SmtpFacade(host, port);
            smtpFacade.Send(from, to, subject, body, null, null);

            Assert.AreEqual(1, server.ReceivedEmailCount);
            var smtpMessage = server.ReceivedEmail[0];
            var recived_body = smtpMessage.MessageParts[0].BodyData;

            Assert.AreEqual(from, smtpMessage.FromAddress.ToString());
            Assert.AreEqual(to, smtpMessage.ToAddresses[0].ToString());
            Assert.AreEqual(subject, smtpMessage.Subject);
            Assert.AreEqual(body, recived_body);
        }
    }
}
