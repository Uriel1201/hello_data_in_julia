using Tables, SQLite
import hello_data_in_julia.DatabaseSetup.MySQLite as dbs


const TABLE_LIST = dbs.get_conn("hello_data", "ro") do conn
    dbs.my_tables(conn)
end


function create_01_users(conn::SQLite.DB)::dbs.MyTable
    t = "users_01"
    schema = Tables.Schema(
        (:user_id, :action, :action_date),
        (Int64, Union{String,Nothing}, Union{String,Nothing}),
    )
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function create_02_transactions(conn::SQLite.DB)::dbs.MyTable
    t = "02_transactions"
    schema = Tables.Schema(
        (:sender, :receiver, :amount, :transaction_date),
        (Int64, Union{Int64,Nothing}, Union{Float64,Nothing}, Union{String,Nothing}),
    )
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function create_03_items(conn::SQLite.DB)::dbs.MyTable
    t = "03_items"
    schema = Tables.Schema((:date, :item), (String, Union{String,Nothing}))
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function create_04_users(conn::SQLite.DB)::dbs.MyTable
    t = "04_users"
    schema = Tables.Schema(
        (:id, :action, :action_date),
        (Int64, Union{String,Nothing}, Union{String,Nothing}),
    )
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function create_05_users(conn::SQLite.DB)::dbs.MyTable
    t = "05_users"
    schema =
        Tables.Schema((:user_id, :product_id, :transaction_date), (Int64, Int64, String))
    if !(t in TABLE_LIST)
        return dbs.create_table(conn, t, schema)
    else
        @info "$t already exists"
        return dbs.mytable(t, schema)
    end
end


function main()
    dbs.get_conn("hello_data", "rw") do conn
        println("uri: $conn connected")

        tables = dbs.MyTable[]
        push!(tables, create_01_users(conn))
        push!(tables, create_02_transactions(conn))
        push!(tables, create_03_items(conn))
        push!(tables, create_04_users(conn))
        push!(tables, create_05_users(conn))

        for table in tables
            println("table:$(table.name), columns: $(table.stmt_columns)")
        end
    end
end


if Base.@isdefined(PROGRAM_FILE) && abspath(PROGRAM_FILE) == abspath(@__FILE__)
    main()
end
