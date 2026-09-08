module MySQLite
using SQLite


"""
    get_conn(dbs::String = ":memory:", mode::String = "default") -> SQLite.DB
"""
function get_conn(dbs::String = ":memory:", mode::String = "default")::SQLite.DB
    if dbs == ":memory:"
        return SQLite.DB()
    end
    path = joinpath("data", "$dbs.sqlite")
    if ispath(path)
        uri = "file:$path?mode=$mode"
        return SQLite.DB(uri)
    else
        uri = "file:$path"
        return SQLite.DB(uri)
    end
end
end # module MySQLite
