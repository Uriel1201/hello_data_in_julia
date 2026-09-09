using Test
include("../src/database_setup/sqlite.jl")
using .MySQLite, DBInterface, SQLite, Arrow, Tables, DataFrames

@testset "MySQLite.get_conn" begin
    MySQLite.get_conn() do conn
        @test conn isa SQLite.DB
        stmt = SQLite.Stmt(conn, "SELECT 'HELLO, WORLD!' AS greet")
        result = DBInterface.execute(stmt)
        row = first(result)
        @test row.greet == "HELLO, WORLD!"
    end
end # testset

@testset "MySQLite.sqlite_to_arrow" begin
    MySQLite.get_conn() do conn
        DBInterface.execute(conn, "CREATE TABLE t (id INTEGER, name TEXT)")
        DBInterface.execute(
            conn,
            "INSERT INTO t VALUES (1,'a'), (2,'b'), (3,'c'), (4,'d'), (5,'e')",
        )

        is_available = MySQLite.isavailable(conn, "t")
        @test is_available == true
        MySQLite.sqlite_to_arrow(conn, "SELECT * FROM t", "test_output")

        @test isfile("data/arrow/test_output.arrow")

        tbl = Arrow.Table("data/arrow/test_output.arrow")
        @test length(tbl.id) == 5
        @test collect(tbl.id) == [1, 2, 3, 4, 5]
        @test collect(tbl.name) == ["a", "b", "c", "d", "e"]
    end

    rm("data/arrow/test_output.arrow"; force = true)
end # testset

@testset "MySQLite.sqlite_sample" begin
    MySQLite.get_conn() do conn
        DBInterface.execute(conn, "CREATE TABLE t (id INTEGER, name TEXT)")
        DBInterface.execute(
            conn,
            "INSERT INTO t VALUES (1,'a'), (2,'b'), (3,'c'), (4,'d'), (5,'e')",
        )

        df = MySQLite.sqlite_sample(conn, "SELECT * FROM t")
        @test df isa DataFrame
        @test nrow(df) == 5
        @test names(df) == ["id", "name"]
        @test df.name == ["a", "b", "c", "d", "e"]
    end
end # testset
