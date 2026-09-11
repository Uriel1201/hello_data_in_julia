module MySQLite

using SQLite, Arrow, DBInterface, Tables, DataFrames


struct MyTable
    name::String
    stmt_columns::String
end


"""
    get_conn(f::Function, db_path::String = ":memory:", mode::String = "default")
"""
function get_conn(f::Function, db_path::String = ":memory:", mode::String = "default")
    if db_path == ":memory:"
        db = SQLite.DB()
    else
        path = joinpath("data", "$db_path.sqlite")
        uri = ispath(path) ? "file:$path?mode=$mode" : "file:$path"
        db = SQLite.DB(uri)
    end
    try
        return f(db)
    finally
        SQLite.close(db)
    end
end #get_conn


"""
    sqlite_to_arrow(conn::SQLite.DB, query::String, output_file::String)
"""
function sqlite_to_arrow(conn::SQLite.DB, query::String, output_file::String)::Nothing

    file_path = joinpath("data/arrow", "$output_file.arrow")

    result = DBInterface.execute(conn, query)

    open(Arrow.Writer, file_path) do writer

        batch = NamedTuple[]

        for row in result
            push!(batch, NamedTuple(row))

            if length(batch) == 10000
                table = Tables.columntable(batch)
                Arrow.write(writer, table)

                batch = NamedTuple[]
            end
        end

        if !isempty(batch)
            table = Tables.columntable(batch)
            Arrow.write(writer, table)
        end
    end

    nothing
end #sqlite_to_arrow


"""
    sqlite_sample(conn::SQLite.DB, query::String) -> DataFrame
"""
function sqlite_sample(conn::SQLite.DB, query::String)::DataFrame
    result = DBInterface.execute(conn, query)
    batch = NamedTuple[]
    for row in Iterators.take(result, 100)
        push!(batch, NamedTuple(row))
    end
    return DataFrame(batch)
end # sqlite_sample


"""
    print_sqlite(conn::SQLite.DB, query::String) -> Nothing 
"""
function print_sqlite(conn::SQLite.DB, query::String)::Nothing
    show(sqlite_sample(conn, query))
    nothing
end # print_sqlite


"""
    my_tables(conn::SQLite.DB) -> Vector{String}
"""
function my_tables(conn::SQLite.DB)::Vector{String}
    list_tables = collect(SQLite.tables(conn))
    return [t.name for t in list_tables]
end # my_tables


"""
    mytable(table_name::String, schema::Tables.Schema) -> MyTable
"""
function mytable(table_name::String, schema::Tables.Schema)::MyTable
    columns = "(" * join([String(column) for column in schema.names], ", ") * ")"
    return MyTable(table_name, columns)
end # mytable


"""
    create_table(conn::SQLite.DB, table_name::String, schema::Tables.Schema) -> MyTable
"""
function create_table(conn::SQLite.DB, table_name::String, schema::Tables.Schema)::MyTable
    list_table = my_tables(conn)
    if !(table_name in list_table)
        SQLite.createtable!(conn, table_name, schema, temp = false)

        columns = join(schema.names, " | ")
        _type = join(schema.types, " | ")
        @info "$table_name created: " columns _type
    else
        @info "$table_name already exists"
    end
    return mytable(table_name, schema)
end # create_table


"""
    ingest_data(conn::SQLite.DB, my_table::MyTable, data) -> Nothing 
"""
function ingest_data(conn::SQLite.DB, my_table::MyTable, data)::Nothing
    list_table = my_tables(conn)
    if (my_table.name in list_table)
        n = length(first(data))
        placeholders = join(["(" * join(fill("?", n), ", ") * ")" for _ in data], ", ")

        query = "INSERT INTO $(my_table.name) $(my_table.stmt_columns) VALUES $placeholders"
        stmt = SQLite.Stmt(conn, query)
        params = collect(Iterators.flatten(data))
        DBInterface.execute(stmt, params)
        @info "ingestion completed"
    else
        error("$my_table.name does not exist")
    end
    nothing
end # ingest_data
end # module MySQLite
