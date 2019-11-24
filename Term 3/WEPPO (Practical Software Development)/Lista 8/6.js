var mssql = require('mssql');

class ParentRepository {
    constructor( conn ) {
        this.conn = conn;
    }

    async retrieve(name) {
        try {
            var req = new mssql.Request( this.conn );
            if ( !name ) {
                var res = await req.query( 'select * from NAZWISKA');

                return res.recordset;
            }

            req.input('name', name);
            var res = await req.query( 'select * from NAZWISKA where Nazwisko=@name' );

            return res.recordset[0];
        }
        catch ( err ) {
            console.log( err );
            return [];
        }
    }

    async retrieve2(id) {
        try {
            var req = new mssql.Request( this.conn );

            req.input('id', id);
            var res = await req.query( 'select * from NAZWISKA where ID=@id' );

            return res.recordset[0];
        }
        catch ( err ) {
            console.log( err );
            return [];
        }
    }

    async insert(nazwisko) {
        if ( !nazwisko ) return;
        try {
            var req = new mssql.Request( this.conn );
            req.input("Nazwisko",nazwisko)
            var res = await req.query( 'insert into NAZWISKA (Nazwisko) values (@Nazwisko) select scope_identity() as id');
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

        //await repo.insert("Kowalski" + 2)

        // for (let i = 3; i < 1000000; i++) {
        //     await repo.insert("Kowalski" + i.toString());
        // }
        // for (let i = 0; i < 100; i++) {
        //     for (let j = 0; j < 10000; j++) {
        //         await repo.insert("Kowalski" + (i*100 + j).toString());
        //     }
        //     console.log(i,"%");
        // }

        // items.forEach( e => {
        //     console.log( JSON.stringify(e));
        // });

        var start = Date.now();

        var item = await repo.retrieve(name = "Kowalski946130");
        //var item = await repo.retrieve2(946130)

        console.log(item)
        var stop = Date.now();
        console.log(stop-start)
        
        conn.close()
        
        // PS C:\Studia\3 semestr\WEPPO\Lista 8> node 6.js
        // { ID: 946130, Nazwisko: 'Kowalski946130                ' }
        // 142
        // PS C:\Studia\3 semestr\WEPPO\Lista 8> node 6.js
        // { ID: 946130, Nazwisko: 'Kowalski946130                ' }
        // 20

    }
    catch ( err ) {
        if ( conn.connected )
            conn.close();
            console.log( err );
    }
}

main();
