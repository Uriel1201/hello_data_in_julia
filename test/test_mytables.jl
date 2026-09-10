using Test
include("../data/my_tables.jl")
using .MyTables, Tables, DBInterface
import hello_data_in_julia.DatabaseSetup.MySQLite as dbs

schema = Tables.Schema((:id, :animal, :name), (Int32, String, String))
data = [(1, "dog", "Margarita"), (2, "cat", "Michi"), (3, "bird", "Pantaleon")]

@testset "MyTables.create_table" begin
    dbs.get_conn() do conn
        @test !("family" in dbs.my_tables(conn))
        my_table = MyTables.create_table(conn, "family", schema)
        @test my_table.name == "family"
        @test my_table.stmt_columns == "(id, animal, name)"
        @test ("family" in dbs.my_tables(conn))
        MyTables.ingest_data(conn, my_table, data)
        result = DBInterface.execute(conn, "SELECT name FROM family WHERE animal = 'dog'")
        row = first(result)
        @test row.name == "Margarita"
    end
end # testset
