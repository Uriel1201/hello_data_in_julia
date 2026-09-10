module MyTables
using DBInterface, SQLite, Tables

"""
"""
function create_users_01(conn::SQLite.DB, list_table::Vector{String})::Nothing

    if !("users_01" in list_table)
        schema = Tables.Schema((:user_id, :action, :dates), (Int32, String, String))
        SQLite.createtable!(conn, "users_01", schema, temp = false)

        columns = join(schema.names, " | ")
        _type = join(schema.types, " | ")
        @info "users_01 created:" columns _type
    else
        @info "users_01 already exists"
    end
    nothing
end # create_users_01


"""
"""
function users_01_ingest(conn::SQLite.DB, data::Vector{Tuple{Int64, String, String}})::Nothing
    placeholders = join(["(?, ?, ?)" for _ in data], ", ")
    query = "INSERT INTO USERS_01 (USER_ID, ACTION, DATES) VALUES $placeholders"
    stmt = SQLite.Stmt(conn, query)
    params = collect(Iterators.flatten(data))
    DBInterface.execute(stmt, params)
    @info "$data ingested"
end # users_01_ingest
end # module MyTables
