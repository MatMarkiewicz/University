var mssql = require('mssql');

class ParentRepository {
    constructor( conn ) {
        this.conn = conn;
    }

    async retrieve(name = null) {
        try {
            var req = new mssql.Request( this.conn );
            if ( name ) req.input('name', name);

            var res = await req.query( 'select * from OSOBA3' + ( name ? 'where Nazwa=@name' : '') );

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
            var res = await req.query( 'select * from MIEJSCE_PRACY3');

            return res.recordset;
        }
        catch ( err ) {
            console.log( err );
            return [];
        }
    }

    async retrieve3() {
        try {
            var req = new mssql.Request( this.conn );
            var res = await req.query( 'select * from RELACJA');

            return res.recordset;
        }
        catch ( err ) {
            console.log( err );
            return [];
        }
    }

    async insert(osoba,miejsce_pracy) {
        if ( !osoba || !miejsce_pracy) return;
        try {
            var req = new mssql.Request( this.conn );
            req.input("mp", miejsce_pracy.Nazwa)
            req.input("Imie", osoba.Nazwa);
            var res0 = await req.query( 'insert into MIEJSCE_PRACY3 (Nazwa) values (@mp) select scope_identity() as id0' )
            var id0 = res0.recordset[0].id0
            var res1 = await req.query( 'insert OSOBA3 (Nazwa) values (@Imie) select scope_identity() as id1' )
            var id1 = res1.recordset[0].id1
            req.input("Miejsce_p",id0)
            req.input("Osoba",id1)
            var res = await req.query( 'insert into RELACJA (ID_OSOBA,ID_MIEJSCE_PRACY) values (@Osoba,@Miejsce_p) select scope_identity() as id');
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

        var os = {
            Nazwa: "NoweImie",
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
        var items = await repo.retrieve3();
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