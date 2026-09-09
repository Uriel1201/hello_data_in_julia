module MySQLite

using SQLite, Arrow, DBInterface, Tables, DataFrames


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
end


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
end


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
end


"""
    print_sqlite(conn::SQLite.DB, query::String) -> Nothing 
"""
function print_sqlite(conn::SQLite.DB, query::String)::Nothing
    show(sqlite_sample(conn, query))
    nothing
end


"""
    my_tables(conn::SQLite.DB) -> Vector{String}
"""
function my_tables(conn::SQLite.DB)::Vector{String}
    list_tables = collect(SQLite.tables(conn))
    return [t.name for t in list_tables]
end
end # module MySQLite
