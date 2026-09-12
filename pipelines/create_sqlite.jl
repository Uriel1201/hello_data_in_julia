using Tables, SQLite, CSV
import hello_data_in_julia.DatabaseSetup.MySQLite as dbs


const TABLE_LIST = dbs.get_conn() do conn
    dbs.my_tables(conn)
end


function create_01_users(conn::SQLite.DB, schema::Tables.Schema)::dbs.MyTable
    t = "users_01"
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function create_02_transactions(conn::SQLite.DB, schema::Tables.Schema)::dbs.MyTable
    t = "02_transactions"
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function create_03_items(conn::SQLite.DB, schema::Tables.Schema)::dbs.MyTable
    t = "03_items"
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function create_04_users(conn::SQLite.DB, schema::Tables.Schema)::dbs.MyTable
    t = "04_users"
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function create_05_users(conn::SQLite.DB, schema::Tables.Schema)::dbs.MyTable
    t = "05_users"
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function main() 
    dbs.get_conn() do conn
        println("uri: $conn connected")

        file_01 = "data/csv/01"
        path_01 = joinpath.(file_01, filter(f -> endswith(f, ".csv"), readdir(file_01)))
        csv_01 = CSV.File(path_01)
        schema_01 = Tables.Schema((:user_id, :action, :action_date), Tables.schema(csv_01).types)
        users_01 = create_01_users(conn, schema_01)
        dbs.ingest_data(conn, users_01, csv_01)

        #_02 = create_02_transactions(conn)
        #_03 = create_03_items(conn)
        #_05 = create_04_users(conn)
        #_06 = create_05_users(conn)
    end
end


if Base.@isdefined(PROGRAM_FILE) &&
   abspath(PROGRAM_FILE) == abspath(@__FILE__)
    main()
end
