var mssql = require('mssql');

async function main() {
    var conn = new mssql.ConnectionPool(
    'server=localhost,1433;database=WEPPO;user id=Mateusz;password=321');
    try {
        await conn.connect();   
        var request = new mssql.Request(conn);
        var result = await request.query('select * from OSOBA');
        result.recordset.forEach( r => {
            console.log( r );
        })
        await conn.close();
    }
    catch ( err ) {
        if ( conn.connected )
        conn.close();
        console.log( err );
    }
}

main();