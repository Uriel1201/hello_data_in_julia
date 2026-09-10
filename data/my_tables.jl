module MyTables

using DBInterface, SQLite, Tables
import hello_data_in_julia.DatabaseSetup.MySQLite as dbs

struct MyTable
    name::String
    stmt_columns::String
end


"""
"""
function get_my_table(table_name::String, schema::Tables.Schema)::MyTable
    columns = "(" * join([String(column) for column in schema.names], ", ") * ")"
    return MyTable(table_name, columns)
end


"""
"""
function create_table(conn::SQLite.DB, table_name::String, schema::Tables.Schema)::MyTable
    list_table = dbs.my_tables(conn)
    if !(table_name in list_table)
        SQLite.createtable!(conn, table_name, schema, temp = false)

        columns = join(schema.names, " | ")
        _type = join(schema.types, " | ")
        @info "$table_name created: " columns _type
    else
        @info "$table_name already exists"
    end
    return get_my_table(table_name, schema)
end # create_table


"""
"""
function ingest_data(conn::SQLite.DB, my_table::MyTable, data::Vector{<:Tuple})::Nothing
    list_table = dbs.my_tables(conn)
    if (my_table.name in list_table)
        n = length(first(data))
        placeholders = join(
            ["(" * join(fill("?", n), ", ") * ")" for _ in data],
            ", "
        )

        query = "INSERT INTO $(my_table.name) $(my_table.stmt_columns) VALUES $placeholders"
        stmt = SQLite.Stmt(conn, query)
        params = collect(Iterators.flatten(data))
        DBInterface.execute(stmt, params)
        @info "$data ingested"
    else
        error("$my_table.name does not exist")
    end
    nothing 
end # ingest_data
end # module MyTables
