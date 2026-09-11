using Tables, SQLite
import hello_data_in_julia.DatabaseSetup.MySQLite as dbs


table_list = dbs.get_conn("hello_sqlite", "ro") do conn
    dbs.my_tables(conn)
end


function create_01_users(conn::SQLite.DB)::dbs.MyTable
    if !("01_users" in table_list)
        schema = Tables.Schema((:user_id, :action, :action_date), (Int32, String, String))
        return dbs.create_table(conn, "01_users", schema)
    else
        @info "01_users already exists"
    end
end


if Base.@isdefined(PROGRAM_FILE) &&
   abspath(PROGRAM_FILE) == abspath(@__FILE__)

    dbs.get_conn("hello_sqlite", "rw") do conn
        println("uri: $conn connected")
        create_01_users(conn)
    end

end
