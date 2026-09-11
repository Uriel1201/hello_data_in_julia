using Test
include("../data/my_tables.jl")
using .MyTables, Tables, DBInterface, CSV
import hello_data_in_julia.DatabaseSetup.MySQLite as dbs

schema1 = Tables.Schema((:id, :animal, :name), (Int32, String, String))
schema = Tables.Schema((:USER_ID, :ACTION, :DATES), (Int32, String, Union{Missing,String}))
data = [(1, "dog", "Margarita"), (2, "cat", "Michi"), (3, "bird", "Pantaleon")]
file = CSV.File("data/csv/01/cancel.csv")

@testset "MyTables.create_table" begin
    dbs.get_conn() do conn
        @test !("family" in dbs.my_tables(conn))

        my_table = MyTables.create_table(conn, "family", schema1)
        @test my_table.name == "family"
        @test my_table.stmt_columns == "(id, animal, name)"
        @test ("family" in dbs.my_tables(conn))

        tbl = MyTables.create_table(conn, "users", schema)
        @test tbl.name == "users"
        @test tbl.stmt_columns == "(USER_ID, ACTION, DATES)"
        @test ("users" in dbs.my_tables(conn))

        MyTables.ingest_data(conn, my_table, data)
        result = DBInterface.execute(conn, "SELECT name FROM family WHERE animal = 'dog'")
        row = first(result)
        @test row.name == "Margarita"

        MyTables.ingest_data(conn, tbl, file)
        result = DBInterface.execute(
            conn,
            "SELECT COUNT(*) as num_of_rows FROM users WHERE ACTION = 'cancel'",
        )
        row = first(result)
        @test row.num_of_rows == 4
    end
end # testset
