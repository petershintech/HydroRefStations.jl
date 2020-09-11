"""Save all data types of one HRS site.
"""

using HydroRefStations
using CSV

hrs = HRS()

awrc_id = "410730" # Cotter River at Gingera
for (tscale, data_types) in hrs.data_types
    for data_type in data_types
        data, header = get_data(hrs, awrc_id, data_type)
        tag = join(split(data_type), "_")
        data |> CSV.write("st_$(awrc_id)_$(tag).csv")
    end
end