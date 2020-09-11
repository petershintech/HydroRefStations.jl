"""Download annual data of all HRS sites and save them to CSV files.
"""

using HydroRefStations
using CSV

hrs = HRS()

for awrc_id in hrs.sites[!,"AWRC Station Number"]
    data, header = get_data(hrs, awrc_id, "annual data")
    data |> CSV.write("st_$(awrc_id)_annual_data.csv")
end