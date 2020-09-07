"""
A web client for the Hydrologic Reference Stations of the Australian Bureau of Meteorology
at http://www.bom.gov.au/water/hrs.
"""
module HydroRefStations

import HTTP
import CSV
using DataStructures: OrderedDict
using DataFrames: DataFrame, rename, rename!, vcat, sort!
using Dates

export get_sites, get_data_types, get_data

const HRS_URL = "http://www.bom.gov.au/water/hrs/"
const SITES_URL = HRS_URL * "content/hrs_station_details.csv"
const DATA_URL = HRS_URL * "content/data/"

const HEADER_DELIM = "#"

const URL_SUFFIXES = OrderedDict(
    "daily data" => "daily_ts",
    "daily flow duration curve" => "daily_fdc_linear",
    "event frequency analysis" => "daily_event_histogram_frequency",
    "event volume analysis" => "daily_event_histogram_volume",

    "monthly data" => "",
    "january data" => "monthly_total_01",
    "february data" => "monthly_total_02",
    "march data" => "monthly_total_03",
    "april data" => "monthly_total_04",
    "may data" => "monthly_total_05",
    "june data" => "monthly_total_06",
    "july data" => "monthly_total_07",
    "august data" => "monthly_total_08",
    "september data" => "monthly_total_09",
    "october data" => "monthly_total_10",
    "november data" => "monthly_total_11",
    "december data" => "monthly_total_12",
    "january anomaly" => "monthly_anomaly_01",
    "february anomaly" => "monthly_anomaly_02",
    "march anomaly" => "monthly_anomaly_03",
    "april anomaly" => "monthly_anomaly_04",
    "may anomaly" => "monthly_anomaly_05",
    "june anomaly" => "monthly_anomaly_06",
    "july anomaly" => "monthly_anomaly_07",
    "august anomaly" => "monthly_anomaly_08",
    "september anomaly" => "monthly_anomaly_09",
    "october anomaly" => "monthly_anomaly_10",
    "november anomaly" => "monthly_anomaly_11",
    "december anomaly" => "monthly_anomaly_12",
    "monthly boxplot" => "monthly_boxplot",

    "seasonal data" => "",
    "summer data" => "seasonal_total_Summer",
    "autumn data" => "seasonal_total_Autumn",
    "winter data" => "seasonal_total_Winter",
    "spring data" => "seasonal_total_Spring",
    "summer anomaly" => "seasonal_anomaly_Summer",
    "autumn anomaly" => "seasonal_anomaly_Autumn",
    "winter anomaly" => "seasonal_anomaly_Winter",
    "spring anomaly" => "seasonal_anomaly_Spring",
    "seasonal boxplot" => "seasonal_boxplot",

    "annual data" => "annual_total",
    "cease to flow" => "annual_total_cease_to_flow",
    "annual anomaly" => "annual_anomaly",
    "3 year moving average" => "annual_anomaly_3MA",
    "5 year moving average" => "annual_anomaly_5MA",
    "11 year moving average" => "annual_anomaly_11MA"
)

const DATA_TYPES = collect(keys(URL_SUFFIXES))
const IMONTH = findfirst(isequal("monthly data"), DATA_TYPES)
const ISEASON = findfirst(isequal("seasonal data"), DATA_TYPES)
const IYEAR = findfirst(isequal("annual data"), DATA_TYPES)

const COMPOSITE_DATA_ATTRS = Dict(
    "seasonal data" => Dict(
        "data types" => ["autumn data", "winter data", "spring data", "summer data"],
        "months" => 3:3:12,
        "column name" =>  "Seasonal streamflow (ML/season)"),
    "monthly data" => Dict(
        "data types" => [
            "january data", "february data", "march data", "april data", "may data",
            "june data", "july data", "august data", "september data", "october data",
            "november data", "december data"],
        "months" => 1:12,
        "column name" =>  "Monthly streamflow (ML/season)")
)

"""
    data, header = get_sites()

Return the information of sites e.g. AWRC ID, name and location.

# Examples
```julia
julia> sites, header = get_sites();
julia> sites
467×8 DataFrame. Omitted printing of 6 columns
│ Row │ AWRC Station Number │ Station Name                              │
│     │ String              │ String                                    │
├─────┼─────────────────────┼───────────────────────────────────────────┤
│ 1   │ 410713              │ Paddy's River at Riverlea                 │
│ 2   │ 410730              │ Cotter River at Gingera                   │
...
```
"""
function get_sites()::Tuple{DataFrame,Array{String,1}}
    r = HTTP.get(SITES_URL)

    body_buf = IOBuffer(String(r.body))
    header = extract_header!(body_buf, HEADER_DELIM)
    new_header = prune_header(header, HEADER_DELIM)

    body_buf = seek(body_buf, 0)
    sites = CSV.read(body_buf, comment=HEADER_DELIM)

    return sites, new_header
end

"""
    data_types = get_data_types([tscale::AbstractString])

Return an array of supported data types. Note that "monthly data" and "seasonal data" are
used to return a time series of all monthly data (or seasonal data).

# Arguments
* `tscale`: Temporal scale. ["all", "day", "month", "season", "year"].
            The default value is "all".

# Examples
```julia
julia> get_data_types()
44-element Array{String,1}:
 "daily data"
 "daily flow duration curve"
 "event frequency analysis"
 "event volume analysis"
...
```
"""
function get_data_types(tscale::AbstractString="all")::Array{String,1}
    if tscale == "all"
        return DATA_TYPES
    elseif tscale == "day"
        return DATA_TYPES[1:IMONTH-1]
    elseif tscale == "month"
        return DATA_TYPES[IMONTH:ISEASON-1]
    elseif tscale == "season"
        return DATA_TYPES[ISEASON:IYEAR-1]
    elseif tscale == "year"
        return DATA_TYPES[IYEAR:end]
    else
        throw(ArgumentError("Invalid time scale: $(tscale)"))
    end
end

"""
    data, header = get_data(awrc_id::AbstractString, data_type::AbstractString)

Return the data of a site.

# Arguments
* `awrc_id`: AWRC ID of the site. The ID can found in the table from `get_sites()`
* `data_type`: Type of the data. The data type string can be found in an array from `get_data_types()`

# Examples
```julia
julia> data, header = get_data("410730", "annual data");
julia> data
55×2 DataFrame
│ Row │ Water Year (March to February) │ Annual streamflow (GL/water year) │
│     │ Int64                          │ Float64                           │
├─────┼────────────────────────────────┼───────────────────────────────────┤
│ 1   │ 1964                           │ 80.3924                           │
│ 2   │ 1965                           │ 19.7936                           │
...
```
"""
function get_data(awrc_id::AbstractString,
                  data_type::AbstractString)::Tuple{DataFrame,Array{String,1}}
    if data_type ∉ DATA_TYPES
        throw(ArgumentError("Unsupported data type, $(data_type)."))
    else
        url_suffix = URL_SUFFIXES[data_type]
        if length(url_suffix) > 0
            return get_raw_data(awrc_id, data_type)
        else
            return get_composite_data(awrc_id, data_type)
        end
    end
end

"""
    data, header = get_raw_data(awrc_id::AbstractString, data_type::AbstractString)

Download multiple datasets, combine them to a time series.
"""
function get_raw_data(awrc_id::AbstractString,
                      data_type::AbstractString)::Tuple{DataFrame,Array{String,1}}

    url = get_url(awrc_id, data_type)
    r = HTTP.get(url)

    body_buf = IOBuffer(String(r.body))

    header = extract_header!(body_buf, HEADER_DELIM)
    new_header = prune_header(header, HEADER_DELIM)

    body_buf = seek(body_buf, 0)
    data = CSV.read(body_buf, comment=HEADER_DELIM)

    return data, new_header
end

"""
    data, header = get_composite_data(awrc_id::AbstractString, data_type::AbstractString)

Download multiple datasets and combine them to a time series.
"""
function get_composite_data(awrc_id::AbstractString,
                            data_type::AbstractString)::Tuple{DataFrame,Array{String,1}}
    attrs = COMPOSITE_DATA_ATTRS[data_type]
    data_list = []
    header = [""]
    for i in 1:length(attrs["data types"])
        dtype = attrs["data types"][i]
        data, header = get_raw_data(awrc_id, dtype)
        rename!(data, [:Year, :Q])
        data[!,:Date] = [Date(year, attrs["months"][i], 1) for year in data.Year]
        push!(data_list, data)
    end

    composite_data = vcat(data_list...)
    sort!(composite_data, :Date)
    composite_data = rename(composite_data[:,[:Date, :Q]],
                            ["Start Date", attrs["column name"]])

    return composite_data, header
end

"""
    url = get_url(awrc_id::AbstractString, data_type::AbstractString)

Return the URL to download data of a site.
"""
function get_url(awrc_id::AbstractString, data_type::AbstractString)::AbstractString
    url_suffix = URL_SUFFIXES[data_type]
    url = "$(DATA_URL)/$(awrc_id)/$(awrc_id)_$(url_suffix).csv"
    return url
end

"""
    header = extract_header!(body_buf::Base.GenericIOBuffer{Array{UInt8,1}}, delim::AbstractString)

Return the header document of the data file. Note that it moves the position of body_buf.
"""
function extract_header!(body_buf::Base.GenericIOBuffer{Array{UInt8,1}},
                         delim::AbstractString)::Array{String,1}
    header = String[]
    for line in eachline(body_buf)
        startswith(line, delim) ? push!(header, line) : break
    end
    return header
end

"""
    new_header = prune_header(header::AbstractString, delim::AbstractString)

Prune the extracted header document. It drops blank lines and double quotations from the raw document.
"""
function prune_header(header::Array{String,1}, delim::AbstractString)::Array{String,1}
    new_header = String[]
    for line in header
        #TODO: Give more information about the format error.
        startswith(line, delim) || throw(IOError("A header line does not start with $(delim)."))

        the_line = rstrip(line[2:end])
        if length(the_line) <= 0; continue end
        istart = 1
        i = findfirst('\"', the_line)
        if !isnothing(i); istart = i+1 end
        iend = length(the_line)
        if the_line[end] == '\"'; iend -= 1 end

        push!(new_header, the_line[istart:iend])
    end
    return new_header
end

end