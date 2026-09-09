module MySQLite

using SQLite, Arrow, DBInterface, Tables


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
    sqlite_ti_arrow(conn::SQLite.DB, query::String, output_file::String, chunk_size::Int64)
"""
function sqlite_to_arrow(
    conn::SQLite.DB,
    query::String,
    output_file::String,
    chunk_size::Int64,
)::Nothing

    file_path = joinpath("data/arrow", "$output_file.arrow")

    result = DBInterface.execute(conn, query)

    open(Arrow.Writer, file_path) do writer

        batch = NamedTuple[]

        for row in result
            push!(batch, NamedTuple(row))

            if length(batch) == chunk_size
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
end # module MySQLite
