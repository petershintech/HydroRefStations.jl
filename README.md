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
using HydroRefStations
````

## Site Information

````julia
sites, header = get_sites()
````

## Data Types

`get_data_types()` returns all available data types as an array of strings. For instance, `"daily data"` is used to download daily streamflow data and `"annual total"` is used to download annual total streamflow data.

````julia
data_types = get_data_types()
````

## Data

`get_data()` returns data  as `DataFrames.DataFrame`. The method needs AWRC ID and data type. The AWRC ID of a station can be found in the site information from `get_sites()` and the string of a data type can be found in the array of data types from `get_data_types()`.

````julia
awrc_id = "410730"
data, header = get_data(awrc_id, "daily data")
````

## Disclaimer

This project is not related to or endorsed by the Australian Bureau of Meteorology (BOM). 

Please find copyright of materials downloaded from the Hydrologic Reference Stations website at [copyright notice](http://www.bom.gov.au/water/hrs/copyright.shtml).

[travis-img]: https://travis-ci.org/petershintech/HydroRefStations.jl.svg?branch=master
[travis-url]: https://travis-ci.org/petershintech/HydroRefStations.jl

[codecov-img]: https://codecov.io/gh/petershintech/HydroRefStations.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/petershintech/HydroRefStations.jl
