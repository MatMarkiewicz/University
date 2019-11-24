import html.parser
import urllib.request

class URLParser(html.parser.HTMLParser):
    def __init__(self):
        super().__init__()
        self.urls = []

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for (atr, val) in attrs:
                if atr == 'href' and val.startswith('http'):
                    self.urls.append(val)

myparser = MyHTMLParser()

fp = urllib.request.urlopen("http://ii.uni.wroc.pl/")
mybytes = fp.read()

mystr = mybytes.decode("utf8")
fp.close()

myparser.feed(mystr)
