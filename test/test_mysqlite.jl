using Test
include("../src/database_setup/sqlite.jl")
using .MySQLite, DBInterface

@testset "MySQLite.get_conn" begin
    MySQLite.get_conn() do conn
        @test conn isa SQLite.DB
        stmt = SQLite.Stmt(conn, "SELECT 'HELLO, WORLD!' AS greet")
        result = DBInterface.execute(stmt)
        row = first(result)
        @test row.greet == "HELLO, WORLD!"
    end
end #testset
