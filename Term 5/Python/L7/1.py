import urllib
from bs4 import BeautifulSoup
from bs4.element import Comment
import re
from multiprocessing import Pool,cpu_count

def make_soup(url):
    try:
        page = urllib.request.urlopen(url)
    except urllib.request.HTTPError as e:
        print(f'Failed at {url}: {e}')
        return
    req = urllib.request.Request(url)
    page = urllib.request.urlopen(req).read()
    soup = BeautifulSoup(page, "html.parser")
    return soup

def links_from_url(url):
    soup = make_soup(url)
    if not soup:
        return []
    hrefs = []
        
    for link in soup.find_all('a'):
        hrefs.append(link.get('href'))
        
    ans = []
    for link in hrefs:
        if link is None or len(link) == 0:
            continue
        if link.find('https') != -1 or link.find('http') != -1:
            ans.append(link)
        else:
            sub_sites = link.split('/')
            if len(sub_sites) > 1:
                key_word = '/' + sub_sites[1] + '/'
                pos = url.find(key_word)
                if pos != -1:
                    ans.append(url[:pos] + link)
                else:
                    ans.append(url + link)
          
    return ans

def is_tag_visible(tag):
    if isinstance(tag, Comment):
        return False
    if tag.parent.name in ['style', 'script', 'head', 'title', 'meta', '[document]']:
        return False
    return True

def text_from_url(url):
    soup = make_soup(url)
    if not soup:
        return ''
    texts = soup.findAll(text=True)
    visible_texts = filter(is_tag_visible, texts)  
    return " ".join(t.strip() for t in visible_texts)

def words_from_url(url):
    text = text_from_url(url)
    text = [re.sub('\W+', '', t) for t in text.lower().split()]
    return list(filter(lambda t: len(t), text))

WORDS = {}

def search(url, step, max_step):
    if step > max_step:
        return
        
    words = words_from_url(url)
    hrefs = links_from_url(url)
    
    for w in words:
        d = WORDS.setdefault(w, dict())
        d[url] = d.get(url,0) + 1
        
    for ref in hrefs:
        search(ref, step + 1, max_step)

def position_links():
    for word,links in WORDS.items():
        l = [(s,a) for s,a in links.items()]
        l.sort(key = lambda x: x[1], reverse = True)
        WORDS[word] = l 
        
def make_dict(url,max_step):
    search(url,0,max_step)
    position_links()

def search_BFS(url,max_steps):
    sites = [url]
    act_lvl_sites = [url]
    WORDS = {}
    cores = cpu_count()

    #getting all url in dist max_steps
    for i in range(max_steps):
        new_lvl_sites = []
        p = Pool(cores)
        new_sites = p.map(links_from_url, act_lvl_sites)
        p.terminate()
        p.join()
        for l_sites in new_sites:
            new_lvl_sites += l_sites
            sites += l_sites
        act_lvl_sites = new_lvl_sites
        
    p = Pool(cores)
    words = p.map(words_from_url,sites)
    
    for i,word_list in enumerate(words):
        url = sites[i]
        for w in word_list:
            d = WORDS.setdefault(w, dict())
            d[url] = d.get(url,0) + 1

    for word,links in WORDS.items():
        l = [(s,a) for s,a in links.items()]
        l.sort(key = lambda x: x[1], reverse = True)
        WORDS[word] = l 

    return WORDS
    
if __name__ == "__main__":
    d = search_BFS("https://en.wikipedia.org/wiki/Carmen_(ballet)",1)
    print(len(d))
    print(d['and'])