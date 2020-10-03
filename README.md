# HydroRefStations

| **Build Status**                                                                                |
|:----------------------------------------------------------------------------------------------- |
 [![][travis-img]][travis-url] [![][codecov-img]][codecov-url]

A web client for the Hydrologic Reference Stations of the Australian Bureau of Meteorology in the Julia programming language. The website at <http://www.bom.gov.au/water/hrs> provides high quality long-term streamflow data of unregulated catchments across Australia and their trend analysis results. With the package, you can download the data and analysis results directly to your Julia programming environment.

## Installation

The package can be installed with the Julia package manager. From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

````julia
pkg> add HydroRefStations
````

If you want to install the package directly from its github development site,

````julia
pkg> add http://github.com/petershintech/HydroRefStations.jl
````

And load the package using the command:

````julia
julia> using HydroRefStations
````

## Site Information and Data Types

When you create an instance of the `HRS` structure, it downloads
site information, header and also stores available data types.

````julia
julia> hrs = HRS();
````

Once it is instantiated, the fields of `hrs` should be considered as read-only so don't try to change any values of the fields.

### Site Information

`hrs.sites` has site information including AWRC ID, description and locations.

````julia
julia> hrs.sites
467×8 DataFrame. Omitted printing of 5 columns
│ Row │ AWRC Station Number │ Station Name                                 │ Latitude │
│     │ String              │ String                                       │ Float64  │
├─────┼─────────────────────┼──────────────────────────────────────────────┼──────────┤
│ 1   │ 410713              │ Paddy's River at Riverlea                    │ -35.3843 │
│ 2   │ 410730              │ Cotter River at Gingera                      │ -35.5917 │
│ 3   │ 410731              │ Gudgenby River at
...

julia> names(hrs.sites)
8-element Array{String,1}:
 "AWRC Station Number"
 "Station Name"
 "Latitude"
 "Longitude"
 "Jurisdiction"
 "Catchment Area (km2)"
 "Data Owner Name"
 "Data Owner Code"
`````

`hrs.header` shows the header of the site information. It includes the URL of the website and the version of data available.

````julia
julia> hrs.header
6-element Array{String,1}:
 "Australian Bureau of Meteorology"
 "Hydrologic Reference Stations"
 "Dataset version: August, 2020"
...
`````

### Data Types

`hrs.data_types` returns all available data types. For instance, `"daily data"` is used to download daily streamflow data and `"annual data"` is about annual total streamflow data.

````julia
julia> hrs.data_types
Dict{String,Array{String,1}} with 4 entries:
  "day"    => ["daily data", "daily flow duration curve", "event frequency analysis", "event vo…
  "month"  => ["monthly data", "january data", "february data", "march data", "april data", "ma…
  "year"   => ["annual data", "cease to flow", "annual anomaly", "3 year moving average", "5 ye…
  "season" => ["seasonal data", "summer data", "autumn data", "winter data", "spring data", "su…

````

If you want to check data types of yearly data,

````julia
julia> hrs.data_types["year"]
6-element Array{String,1}:
 "annual data"
 "cease to flow"
 "annual anomaly"
 "3 year moving average"
 "5 year moving average"
 "11 year moving average"
````

## Data

`get_data()` returns data as `DataFrames.DataFrame`. The method needs AWRC ID and data type. The AWRC ID of a station can be found in `hrs.sites` and the string of a data type can be found in the array from `hrs.data_types`.

````julia
julia> awrc_id = "410730";
julia> data, header = get_data(hrs, awrc_id, "annual data");
julia> data
55×2 DataFrame
│ Row │ Water Year (March to February) │ Annual streamflow (GL/water year) │
│     │ Int64                          │ Float64                           │
├─────┼────────────────────────────────┼───────────────────────────────────┤
│ 1   │ 1964                           │ 80.3924                           │
│ 2   │ 1965                           │ 19.7936                           │
│ 3   │ 1966                           │ 57.0632                           │
...
````

## Disclaimer

This project is not related to or endorsed by the Australian Bureau of Meteorology (BOM).

Please find copyright of materials downloaded from the Hydrologic Reference Stations website at [copyright notice](http://www.bom.gov.au/water/hrs/copyright.shtml).

[travis-img]: https://travis-ci.org/petershintech/HydroRefStations.jl.svg?branch=master
[travis-url]: https://travis-ci.org/petershintech/HydroRefStations.jl

[codecov-img]: https://codecov.io/gh/petershintech/HydroRefStations.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/petershintech/HydroRefStations.jl
