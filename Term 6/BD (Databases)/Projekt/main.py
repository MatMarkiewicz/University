# Mateusz Markiewicz (298653)

import psycopg2 as psg
import sys
import json

def node(node,lat,lon,description):
    query = "INSERT INTO nodes(id,geo,description) VALUES(%s,'SRID=4326;POINT(%s %s)'::geography,%s)"
    cur.execute(query,(node,lon,lat,description))

def catalog(version,nodes):
    query = 'INSERT INTO catalog VALUES(%s, %s)'
    cur.execute(query,[version, len(nodes)])
    for i,node in enumerate(nodes):
        query = 'INSERT INTO route(version,node,routeOrder) VALUES(%s,%s,%s)'
        cur.execute(query,(version,node,i))

def trip(cyclist,date,version):
    query = 'INSERT INTO trip(cyclist,date,version) VALUES(%s,%s,%s)'
    cur.execute(query,(cyclist,date,version))

def point_to_coords(point):
    b,e = point.index('('),point.index(')')
    point = point[b+1:e]
    lon,lat = point.split(' ')
    lat,lon = float(lat),float(lon)
    return lat,lon

def create_nodes_data(tuple):
    lat,lon = point_to_coords(tuple[1])
    return {
        "node": tuple[0],
        "olat": lat,
        "olon": lon,
        "distance": round(tuple[2])
    }

def closest_nodes(ilat,ilon):
    query = "SELECT id, ST_AsText(geo), ST_Distance('SRID=4326;POINT(%s %s)'::geography,geo,true)\
                FROM nodes\
                ORDER BY 3\
                LIMIT 3;"
    cur.execute(query,(ilon,ilat))
    data = cur.fetchall()
    data = [create_nodes_data(e) for e in data]
    return data

def create_party_data(tuple):
    return {
        "ocyclist": tuple[0],
        "node": tuple[1],
        "distance": round(tuple[2])
    }

def party(icyclist,date):
    query = "SELECT acc2.cyclist as ocyclist,acc2.node,ST_Distance(acc1.geo,acc2.geo) as distance FROM accomodation as acc1\
            JOIN accomodation as acc2 USING(date)\
            WHERE acc1.cyclist = %s\
            AND acc1.date = %s::date\
            AND acc2.cyclist != acc1.cyclist\
            AND ST_DWithin(acc1.geo,acc2.geo,20000)\
            ORDER BY 3,1;"
    cur.execute(query,(icyclist,date))
    data = cur.fetchall()
    data = [create_party_data(e) for e in data]
    return data

def guests(node,date):
    query = "SELECT cyclist FROM accomodation\
            WHERE node = %s\
            AND date = %s::date\
            ORDER BY 1;"
    cur.execute(query,(node,date))
    data = cur.fetchall()
    data = [{"cyclist": e[0]} for e in data]
    return data

def cyclists(limit):
    query = "SELECT cyclist, COUNT (trip.cyclist) as no_trips, SUM(routeDists.totalDistance) as distance FROM trip\
            JOIN routeDists USING(version)\
            GROUP BY trip.cyclist\
            ORDER BY 3,1\
            LIMIT %s;"
    cur.execute(query,[limit])
    data = cur.fetchall()
    data = [dict(zip(["cyclist","no_trips","distance"],[e[0],e[1],round(e[2])])) for e in data]
    return data

def return_status(is_error = False,data=None):
    status = "ERROR" if is_error else "OK"
    res = {"status": status}
    if data is not None:
        res["data"] = data
    return json.dumps(res,ensure_ascii=False)
    
def execute_function():
    for order in sys.stdin:
        if len(order)<2:
            return
        order = json.loads(order)
        function = globals()[order['function']]
        args = order['body'].values()
        try:
            data = function(*args)
            print(return_status(False,data))
        except:
            print(return_status(True))

def init():
    with open('database.sql','r',encoding='utf-8') as file:
        try:
            cur.execute(file.read())
            print(return_status(False))
        except:
            print(return_status(True))

def drop():
    query = 'drop table if exists "nodes" cascade;\
            drop table if exists "trip" cascade;\
            drop table if exists "catalog" cascade;\
            drop table if exists "route" cascade;'
    try:
        cur.execute(query)
        print(return_status(False))
    except:
        print(return_status(True))

if __name__ == '__main__':
    conn = psg.connect(
        user = 'app',
        password = 'qwerty',
        database = 'student')
    cur = conn.cursor()

    if len(sys.argv) > 1:
        if sys.argv[1] == '--init':
            init()
        elif sys.argv[1] == '--drop':
            drop()
    else:
        execute_function()

    conn.commit()
    cur.close()
    conn.close()

