using Test

include("../src/database_setup/sqlite.jl")
using .MySQLite, DBInterface, SQLite, Arrow, Tables, DataFrames, CSV

sql = "SELECT * FROM t"
schema1 = Tables.Schema((:id, :animal, :name), (Int32, String, String))
schema = Tables.Schema((:USER_ID, :ACTION, :DATES), (Int32, String, Union{Missing,String}))
data = [(1, "dog", "Margarita"), (2, "cat", "Michi"), (3, "bird", "Pantaleon")]
file = CSV.File("data/csv/01/cancel.csv")


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
        DBInterface.execute(conn, "INSERT INTO t VALUES (1,'a'), (2,'b'), (3,'c'), (4,'d'), (5,'e')")

        MySQLite.sqlite_to_arrow(conn, sql, "test_output")

        @test isfile("data/arrow/test_output.arrow")

        tbl = Arrow.Table("data/arrow/test_output.arrow")
        @test length(tbl.id) == 5
        @test collect(tbl.id) == [1, 2, 3, 4, 5]
        @test collect(tbl.name) == ["a", "b", "c", "d", "e"]
    end

    rm("data/arrow/test_output.arrow"; force=true)
end # testset


@testset "MySQLite.sqlite_sample" begin
    MySQLite.get_conn() do conn
        DBInterface.execute(conn, "CREATE TABLE t (id INTEGER, name TEXT)")
        DBInterface.execute(conn, "INSERT INTO t VALUES (1,'a'), (2,'b'), (3,'c'), (4,'d'), (5,'e')")
        my_tables = MySQLite.my_tables(conn)
        @test "t" in my_tables

        df = MySQLite.sqlite_sample(conn, sql)
        @test df isa DataFrame
        @test nrow(df) == 5
        @test names(df) == ["id", "name"]
        @test df.name == ["a", "b", "c", "d", "e"]
    end
end # testset


@testset "MySQLite.create_table" begin
    MySQLite.get_conn() do conn
        @test !("family" in MySQLite.my_tables(conn))

        my_table = MySQLite.create_table(conn, "family", schema1)
        @test my_table.name == "family"
        @test my_table.stmt_columns == "(id, animal, name)"
        @test ("family" in MySQLite.my_tables(conn))

        tbl = MySQLite.create_table(conn, "users", schema)
        @test tbl.name == "users"
        @test tbl.stmt_columns == "(USER_ID, ACTION, DATES)"
        @test ("users" in MySQLite.my_tables(conn))

        MySQLite.ingest_data(conn, my_table, data)
        result = DBInterface.execute(conn, "SELECT name FROM family WHERE animal = 'dog'")
        row = first(result)
        @test row.name == "Margarita"

        MySQLite.ingest_data(conn, tbl, file)
        result = DBInterface.execute(
            conn,
            "SELECT COUNT(*) as num_of_rows FROM users WHERE ACTION = 'cancel'",
        )
        row = first(result)
        @test row.num_of_rows == 4
    end
end # testset
