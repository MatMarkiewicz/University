import html.parser
import urllib.request
import re


class URLParser(html.parser.HTMLParser):
    def __init__(self):
        super().__init__()
        self.urls = []

    def _is_valid_url(self, string):
        return string.startswith('http')

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for atr, val in attrs:
                if atr == 'href' and self._is_valid_url(val):
                    self.urls.append(val)

class GarbageSearch():
    def __init__(self, starting_URL, depth=1):
        self.urls = [starting_URL]
        self._gather_URLS(starting_URL, depth)

    def __getitem__(self, key):
        res = []
        for url in self.urls:
            n = self._count_occurences(url, key)
            if n:
                res.append((url, n))
        res.sort(key=lambda x: x[1], reverse=True)
        return res

    def _gather_URLS(self, url, depth):
        if depth > 1:
            parser = URLParser()
            with urllib.request.urlopen(url) as page:
                parser.feed(page.read().decode('utf-8'))
            for url in parser.urls:
                if url not in self.urls:
                    self.urls.append(url)
                self._gather_URLS(url, depth-1)

    def _count_occurences(self, url, keyword):
        with urllib.request.urlopen(url) as page:
            return len(re.findall(keyword, page.read().decode('utf-8')))


s = GarbageSearch('https://www.ii.uni.wroc.pl/~marcinm/dyd/python/', 2)
print(s['Python'])