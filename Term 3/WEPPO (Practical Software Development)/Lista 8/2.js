
//INSERT INTO OSOBA0 (Imie,Nazwisko,Płeć,Wiek,ID2) values ('Mateusz','Markiewicz','M',21,NEXT VALUE FOR myID)

var mssql = require('mssql');

class ParentRepository {
    constructor( conn ) {
        this.conn = conn;
    }

    async retrieve(name = null) {
        try {
            var req = new mssql.Request( this.conn );
            if ( name ) req.input('name', name);

            var res = await req.query( 'select * from OSOBA0' + ( name ? 'where Imie=@name' : '') );

            return name ? res.recordset[0] : res.recordset;
        }
        catch ( err ) {
            console.log( err );
            return [];
        }
    }

    async insert(osoba) {
        if ( !osoba) return;
        try {
            var req = new mssql.Request( this.conn );
            req.input("Imie", osoba.Imie);
            req.input("Nazwisko", osoba.Nazwisko);
            req.input("Płeć", osoba.Płeć);
            req.input("Wiek", osoba.Wiek)
            req.input("ID2",osoba.ID2)
            var res = await req.query( 'insert into OSOBA0 (Imie,Nazwisko,Płeć,Wiek,ID2) values (@Imie,@Nazwisko,@Płeć,@Wiek,@ID2) select scope_identity() as id');
            return res.recordset[0].id;
        }
        catch ( err ) {
            console.log( err );
            throw err;
        }
    }

    async update(osoba) {
        if ( !osoba || !osoba.ID ) return;
        try {
            var req = new mssql.Request(this.conn);
            req.input("id", osoba.ID);
            req.input("Imie", osoba.Imie);
            req.input("Nazwisko", osoba.Nazwisko);
            req.input("Płeć", osoba.Płeć);
            req.input("Wiek", osoba.Wiek)
            req.input("ID2",osoba.ID2)            
            var ret = await req.query('update OSOBA0 set Imie=@Imie, Nazwisko=@Nazwisko, Płeć=@Płeć, Wiek=@Wiek, ID2=@ID2 where id=@id');
            return ret.rowsAffected[0];
        }
        catch ( err ) {
            console.log( err );
            throw err;
        }
    }

    async delete(id){
        if (!id) return
        try {
            var req = new mssql.Request(this.conn);
            req.input("id",id)
            await req.query("DELETE FROM OSOBA0 WHERE id=@id")
        }
        catch (err) {
            console.log(err);
            throw err
        }
    }
}

async function main() {
    var conn = new mssql.ConnectionPool('server=localhost,1433;database=WEPPO;user id=Mateusz;password=321');
    try {
        await conn.connect();
        var repo = new ParentRepository(conn);
        // pobierz wszystkie rekordy
        //await repo.delete(6)
        var os = {
            Imie: "NoweImie",
            Nazwisko: "NoweNazwisko",
            Płeć: "M",
            Wiek: 70,
            ID2: 10,
            ID: 8
        }
        //var id = await repo.insert(os);
        //console.log(id)

        //await repo.update(os)

        var items = await repo.retrieve();
        items.forEach( e => {
            console.log( JSON.stringify(e));
        });
        conn.close()
        
    }
    catch ( err ) {
        if ( conn.connected )
            conn.close();
            console.log( err );
    }
}

main();