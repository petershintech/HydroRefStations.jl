using HydroRefStations

using Test
using Dates: Day

@testset "HRS.jl" begin
    hrs = HRS()
    @testset "HRS()" begin
        nrows, ncols = size(hrs.sites)
        @test nrows > 0 # At least one site.
        @test ncols > 0 # At least one column.
        @test length(hrs.header) > 0 # At least one header line
        @test hrs.header[1][1] != '#'
        @test hrs.header[1][1] != ','
        @test hrs.header[end][1] != '#'
        @test hrs.header[end][end] != '\"'

        @test length(hrs.data_types) > 0 # At least one data type.

        data_types = hrs.data_types["year"]
        @test "annual data" in data_types
        @test "11 year moving average" in data_types
        @test "seasonal data" ∉ data_types

        data_types = hrs.data_types["month"]
        @test "monthly data" in data_types
        @test "monthly boxplot" in data_types
        @test "daily data" ∉ data_types
        @test "seasonal data" ∉ data_types
    end

    @testset "get_data()" begin
        awrc_ids = ["410730", "114001A"]
        data_types = ["monthly data", "seasonal data"]
        for awrc_id in awrc_ids
            for data_type in data_types
                data, header = get_data(hrs, awrc_id, data_type)

                local nrows, ncols = size(data)
                @test nrows > 0 # At least one data point.
                @test ncols > 0 # At least one column.

                @test length(header) > 0 # At least one header line
                @test header[end][1] != '#'
                @test header[end][end] != '\"'
                if data_type == "monthly data"
                    # Ignore the first and last 12 months in a case of incomplete dataset.
                    @test maximum(diff(data[!,"Start Date"][13:end-12])) <= Day(31)
                    @test minimum(diff(data[!,"Start Date"][13:end-12])) >= Day(28)
                end
                if data_type == "seasonal data"
                    @test maximum(diff(data[!,"Start Date"][5:end-4])) <= Day(92)
                    @test minimum(diff(data[!,"Start Date"][5:end-4])) >= Day(89)
                end
            end
            @test_throws ArgumentError get_data(hrs, "invalid ID", "daily data")
            @test_throws ArgumentError get_data(hrs, awrc_id, "invalid data type")
        end

        data, header = get_data(hrs, awrc_ids[1], "SEASONAL DATA")
    end
    @testset "show()" begin
        show_str = repr(hrs)
        @test occursin("Hydrologic Reference Stations", show_str)
        @test occursin("AWRC", show_str)
        @test occursin("Catchment", show_str)
    end
    @testset "close()" begin
        close!(hrs)
        @test isempty(hrs.sites)
        @test isempty(hrs.header)
        @test isempty(hrs.data_types)
    end

end