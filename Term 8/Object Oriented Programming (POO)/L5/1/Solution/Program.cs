using System;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.IO;

namespace Solution
{

    public class SmtpFacade {

        private SmtpClient _client;

        public SmtpFacade(string host, int port){
            _client = new SmtpClient(host, port);
        }

        public void Send( string From, string To, 
                            string Subject, string Body,
                            Stream Attachment, string AttachmentMimeType ){
                MailMessage msg = new MailMessage(From, To, Subject, Body);
                if (Attachment != null && AttachmentMimeType != null){
                    msg.Attachments.Add(new Attachment(Attachment, new ContentType(AttachmentMimeType)));
                }
                _client.Send(msg);
            }
        }

    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
        }
    }
}
