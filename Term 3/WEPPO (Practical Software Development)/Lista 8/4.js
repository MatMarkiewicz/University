var mssql = require('mssql');

class ParentRepository {
    constructor( conn ) {
        this.conn = conn;
    }

    async retrieve(name = null) {
        try {
            var req = new mssql.Request( this.conn );
            if ( name ) req.input('name', name);

            var res = await req.query( 'select * from OSOBA' + ( name ? 'where Imie=@name' : '') );

            return name ? res.recordset[0] : res.recordset;
        }
        catch ( err ) {
            console.log( err );
            return [];
        }
    }

    async retrieve2() {
        try {
            var req = new mssql.Request( this.conn );
            var res = await req.query( 'select * from MIEJSCE_PRACY');

            return res.recordset;
        }
        catch ( err ) {
            console.log( err );
            return [];
        }
    }

    async insert(osoba,miejsce_pracy) {
        if ( !osoba) return;
        try {
            var req = new mssql.Request( this.conn );
            req.input("mp", miejsce_pracy.Nazwa)
            req.input("Imie", osoba.Imie);
            req.input("Nazwisko", osoba.Nazwisko);
            req.input("Płeć", osoba.Płeć);
            req.input("Wiek", osoba.Wiek)
            var res0 = await req.query( 'insert into MIEJSCE_PRACY (Nazwa) values (@mp) select scope_identity() as id0' )
            var id0 = res0.recordset[0].id0
            req.input("Miejsce_p",id0)
            var res = await req.query( 'insert into OSOBA (Imie,Nazwisko,Płeć,Wiek,Miejsce_pracy) values (@Imie,@Nazwisko,@Płeć,@Wiek,@Miejsce_p) select scope_identity() as id');
            return res.recordset[0].id;
        }
        catch ( err ) {
            console.log( err );
            throw err;
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
        }
        var mp = {
            Nazwa: "NoweMiejscePracy"
        }
        await repo.insert(os,mp)

        var items = await repo.retrieve();
        items.forEach( e => {
            console.log( JSON.stringify(e));
        });
        var items = await repo.retrieve2();
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