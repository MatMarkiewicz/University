from sqlalchemy import Table, Column, Integer, ForeignKey, create_engine, String
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sys import argv

Base = declarative_base()

class Film(Base):
    __tablename__ = 'film'
    id = Column('id', Integer, primary_key=True)
    title = Column('title', String)
    year = Column('year', Integer)
    director_id = Column(Integer, ForeignKey('director.id'))
    director = relationship('Director', back_populates='films')
    operator_id = Column(Integer, ForeignKey('operator.id'))
    operator = relationship('Operator', back_populates='films')
    producer_id = Column(Integer, ForeignKey('producer.id'))
    producer = relationship('Producer', back_populates='films')
    def __str__(self):
        return f"{self.title}, {self.year}, director: {self.director}, operator: {self.operator}, producer: {self.producer}"

class Director(Base):
    __tablename__ = 'director'
    id = Column('id', Integer, primary_key=True)
    first = Column('first', String)
    last = Column('last', String)
    films = relationship('Film', back_populates='director')
    def __str__(self):
        res = f"{self.first} {self.last}, films: "
        for film in self.films:
            res += f"{film.title} ({film.year}), "
        return res

class Operator(Base):
    __tablename__ = 'operator'
    id = Column('id', Integer, primary_key=True)
    first = Column('first', String)
    last = Column('last', String)
    films = relationship('Film', back_populates='operator')
    def __str__(self):
        res = f"{self.first} {self.last}, films: "
        for film in self.films:
            res += f"{film.title} ({film.year}), "
        return res

class Producer(Base):
    __tablename__ = 'producer'
    id = Column('id', Integer, primary_key=True)
    first = Column('first', String)
    last = Column('last', String)
    films = relationship('Film', back_populates='producer')
    def __str__(self):
        res = f"{self.first} {self.last}, films: "
        for film in self.films:
            res += f"{film.title} ({film.year}), "
        return res

engine = create_engine('sqlite:///database.db')
Base.metadata.create_all(bind=engine)
Session = sessionmaker(bind=engine)

def add_director():
    df = input("Director first name: ")
    dl = input("Director last name: ")
    session = Session()
    new = Director(first=df, last=dl)
    session.add(new)
    session.commit()
    session.close()

def add_operator():
    of = input("Operator first name: ")
    ol = input("Operator last name: ")
    session = Session()
    new = Operator(first=of, last=ol)
    session.add(new)
    session.commit()
    session.close()

def add_producer():
    pf = input("Producer first name: ")
    pl = input("Producer last name: ")
    session = Session()
    new = Producer(first=pf, last=pl)
    session.add(new)
    session.commit()
    session.close()

def add_film():
    title = input("Title: ")
    year = int(input("Release year: "))
    df = input("Director first name: ")
    dl = input("Director last name: ")
    of = input("Operator first name: ")
    ol = input("Operator last name: ")
    pf = input("Producer first name: ")
    pl = input("Producer last name: ")
    session = Session()
    d = session.query(Director).filter_by(first=df,last=dl).first()
    o = session.query(Operator).filter_by(first=of,last=ol).first()
    p = session.query(Producer).filter_by(first=pf,last=pl).first()
    new = Film(title=title,year=year,director=d,operator=o,producer=p)
    session.add(new)
    session.commit()
    session.close()

def all_operators():
    session = Session()
    ops = session.query(Operator).all()
    for op in ops:
        print(op)
    session.close() 

def all_directors():
    session = Session()
    dirs = session.query(Director).all()
    for di in dirs:
        print(di)
    session.close()

def all_producers():
    session = Session()
    prods = session.query(Producer).all()
    for prod in prods:
        print(prod)
    session.close() 

def all_films():
    session = Session()
    films = session.query(Film).all()
    for film in films:
        print(film)
    session.close()
    
if len(argv) == 1:
    print("Select table")
elif argv[1] == 'film':
    if len(argv) > 2 and argv[2] == 'add':
        add_film()
    else:
        all_films()
elif argv[1] == 'director':
    if len(argv) > 2 and argv[2] == 'add':
        add_director()
    else:
        all_directors()
elif argv[1] == 'operator':
    if len(argv) > 2 and argv[2] == 'add':
        add_operator()
    else:
        all_operators()
elif argv[1] == 'producer':
    if len(argv) > 2 and argv[2] == 'add':
        add_producer()
    else:
        all_producers()
else:
    print("Unknown table name")