using HydroRefStations
const HRS = HydroRefStations

using Test
using Dates: Day

@testset "HRS.jl" begin
    @testset "get_sites()" begin
        sites, header = HRS.get_sites()

        nrows, ncols = size(sites)
        @test nrows > 0 # At least one site.
        @test ncols > 0 # At least one column.
        @test length(header) > 0 # At least one header line
        @test header[end][1] != '#'
        @test header[end][end] != '\"'
    end

    @testset "get_data_types()" begin
        data_types = HRS.get_data_types()
        @test length(data_types) > 0 # At least one data type.

        test_types = ["daily data", "december data", "spring anomaly",
                      "cease to flow", "annual data"]

        for test_type in test_types
            @test test_type in data_types
        end

        data_types = HRS.get_data_types("year")
        @test "annual data" in data_types
        @test "11 year moving average" in data_types
        @test "seasonal data" ∉ data_types

        data_types = HRS.get_data_types("month")
        @test "monthly data" in data_types
        @test "monthly boxplot" in data_types
        @test "daily data" ∉ data_types
        @test "seasonal data" ∉ data_types

        @test_throws ArgumentError HRS.get_data_types("invalid")
    end

    @testset "get_data()" begin
        awrc_ids = ["410730", "114001A"]
        data_types = ["monthly data", "seasonal data"]
        for awrc_id in awrc_ids
            for data_type in data_types
                data, header = HRS.get_data(awrc_id, data_type)

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
            @test_throws ArgumentError HRS.get_data(awrc_id, "invalid data type")
        end
    end
end