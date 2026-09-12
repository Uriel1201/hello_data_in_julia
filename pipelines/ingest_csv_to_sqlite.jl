using Tables, SQLite, CSV
import hello_data_in_julia.DatabaseSetup.MySQLite as dbs


#table_name = ARGS[1]
path = ARGS[1]
db_path = joinpath(@__DIR__, ".." ,"data", "csv", path)
if isdir(db_path)
    source = joinpath.(db_path, filter(f -> endswith(f, ".csv"), readdir(db_path)))
    data = CSV.File(source)
elseif isfile(db_path)
    data = CSV.File(db_path)
else
    throw(ArgumentError("The specified path is not a valid file or directory"))
end


if Base.@isdefined(PROGRAM_FILE) && abspath(PROGRAM_FILE) == abspath(@__FILE__)
    println(db_path)
    println("is file: $(isfile(db_path))")
    println("is dir: $(isdir(db_path))")
    println(data)
    
end
