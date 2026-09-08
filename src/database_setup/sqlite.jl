module MySQLite
using SQLite


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
end # module MySQLite
