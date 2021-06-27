using System;
using System.IO;
using System.Text;
using System.Linq;

namespace Solution{

    public class CaesarStream : Stream{
        private Stream _stream;
        private int _shift;

        public CaesarStream(Stream stream, int shift){
            _stream = stream;
            _shift = shift;
        }

        private byte ModifyByte(byte b){
            return (byte)((b+_shift)%(byte.MaxValue+1));
        }

        public override int Read(byte[] buffer, int offset, int count){
            int read = _stream.Read(buffer, offset, count);
            buffer.Select(ModifyByte);
            return read;
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            byte[] new_buffer = buffer.Select(ModifyByte).ToArray();
            _stream.Write(new_buffer, offset, count);
        }

        public override bool CanRead => _stream.CanRead;
        public override bool CanWrite => _stream.CanWrite;
        public override bool CanSeek => _stream.CanSeek;
        public override long Length => _stream.Length;
        public override long Position { get => _stream.Position; set => _stream.Position=value; }
        public override void Flush()
        {
            _stream.Flush();
        }
        public override long Seek(long offset, SeekOrigin origin)
        {
            return _stream.Seek(offset, origin);
        }
        public override void SetLength(long value)
        {
            _stream.SetLength(value);
        }

    }
    class Program
    {
        static void Main(string[] args)
        {
            byte[] buffer = Encoding.UTF8.GetBytes("Wow");
            MemoryStream memStream = new MemoryStream();
            CaesarStream cMemStream = new CaesarStream(memStream, -3);
            cMemStream.Write(buffer, 0, buffer.Length);
            Console.WriteLine(Encoding.UTF8.GetString(memStream.ToArray()));
        }
    }

}
