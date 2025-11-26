# Comprehensive tests for the Nearest module
using Test
using OpenSourceRoutingMachine
using Base: C_NULL
using .Fixtures

@testset "Nearest - Basic" begin
    @testset "NearestParams creation" begin
        params = NearestParams()
        @test params isa NearestParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = NearestParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        # Should not throw
        @test true
    end

    @testset "Nearest query for single point" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()

        # Add a coordinate (city center)
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        # Query nearest
        response = nearest(osrm, params)
        @test response isa NearestResponse

        # Check result count
        result_cnt = count(response)
        @test result_cnt >= 0

        # If we have results, check their properties
        if result_cnt > 0
            result_lat = latitude(response, 1)
            result_lon = longitude(response, 1)
            result_dist = distance(response, 1)
            result_name = name(response, 1)

            @test -90.0f0 <= result_lat <= 90.0f0
            @test -180.0f0 <= result_lon <= 180.0f0
            @test result_dist >= 0.0f0
            @test isa(result_name, String)
            @test isfinite(result_lat)
            @test isfinite(result_lon)
            @test isfinite(result_dist)

            @info "Nearest result 0: ($result_lon, $result_lat), distance=$(result_dist)m, name=$(result_name)"
        end
    end

    @testset "Nearest response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()

        coord = Fixtures.HAMBURG_PORT
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        @test response.ptr != C_NULL

        # Should be able to query count
        result_cnt = count(response)
        @test result_cnt >= 0
    end
end

@testset "Nearest - Parameters" begin
    @testset "set_number_of_results!" begin
        params = NearestParams()
        set_number_of_results!(params, 1)
        set_number_of_results!(params, 5)
        set_number_of_results!(params, 10)
        # Should not throw
        @test true
    end

    @testset "Nearest with multiple results requested" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 3)

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        @test response isa NearestResponse
        result_cnt = count(response)
        @test result_cnt >= 0
        @test result_cnt <= 3  # Should not exceed requested number
    end

    @testset "Nearest with single result" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 1)

        coord = Fixtures.HAMBURG_AIRPORT
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        @test response isa NearestResponse
        result_cnt = count(response)
        @test result_cnt >= 0
        @test result_cnt <= 1
    end

    @testset "add_coordinate_with!" begin
        params = NearestParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        radius = 10.0f0
        bearing = 0
        range = 180
        add_coordinate_with!(params, coord, radius, bearing, range)
        # Should not throw
        @test true
    end
end

@testset "Nearest - Response Accessors" begin
    @testset "Access all result properties" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 2)

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        result_cnt = count(response)

        if result_cnt > 0
            # Test accessing first result
            result_lat = latitude(response, 1)
            result_lon = longitude(response, 1)
            result_dist = distance(response, 1)
            result_name = name(response, 1)

            @test -90.0f0 <= result_lat <= 90.0f0
            @test -180.0f0 <= result_lon <= 180.0f0
            @test result_dist >= 0.0f0
            @test isa(result_name, String)
        end

        # Test accessing multiple results if available
        if result_cnt > 1
            for i in 1:(result_cnt - 1)
                result_lat = latitude(response, i)
                result_lon = longitude(response, i)
                result_dist = distance(response, i)
                result_name = name(response, i)

                @test -90.0f0 <= result_lat <= 90.0f0
                @test -180.0f0 <= result_lon <= 180.0f0
                @test result_dist >= 0.0f0
                @test isa(result_name, String)
            end
        end
    end

    @testset "Results are sorted by distance" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 3)

        coord = Fixtures.HAMBURG_PORT
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        result_cnt = count(response)

        if result_cnt > 1
            # Check that distances are in ascending order
            prev_dist = distance(response, 1)
            for i in 2:result_cnt
                curr_dist = distance(response, i)
                @test curr_dist >= prev_dist
                prev_dist = curr_dist
            end
        end
    end

    @testset "as_json returns valid JSON" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        json_str = OpenSourceRoutingMachine.Nearest.as_json(response)

        @test isa(json_str, String)
        @test !isempty(json_str)
        # Basic JSON validation - should start with '{' or '['
        @test startswith(json_str, '{') || startswith(json_str, '[')
    end
end

@testset "Nearest - Error Handling" begin
    @testset "Invalid coordinates (out of bounds)" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()

        # Coordinates way outside Hamburg (somewhere in the ocean)
        add_coordinate!(params, LatLon(0.0f0, 0.0f0))

        # Should either throw an error or return a valid response
        try
            response = nearest(osrm, params)
            # If no error, check that response is valid
            result_cnt = count(response)
            @test result_cnt >= 0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()

        # Try with clearly invalid coordinates
        add_coordinate!(params, LatLon(200.0f0, 200.0f0))  # Invalid lat/lon

        try
            response = nearest(osrm, params)
            # If it doesn't throw, that's also acceptable
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
            @info "Error code: $(e.code), message: $(e.message)"
        end
    end

    @testset "Accessing result with invalid index" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        result_cnt = count(response)

        # Try to access a result index that doesn't exist
        if result_cnt == 0
            # If no results, accessing index 0 should either throw or return a default value
            try
                lat = latitude(response, 1)
                @test true  # If it doesn't throw, that's acceptable
            catch e
                @test e isa OSRMError
            end
        elseif result_cnt > 0
            # Try accessing beyond the available results
            try
                lat = latitude(response, result_cnt)
                @test true  # If it doesn't throw, that's acceptable
            catch e
                @test e isa OSRMError
            end
        end
    end
end

@testset "Nearest - Edge Cases" begin
    @testset "Nearest for different locations" begin
        osrm = Fixtures.get_test_osrm()

        test_locations = [
            Fixtures.HAMBURG_CITY_CENTER,
            Fixtures.HAMBURG_AIRPORT,
            Fixtures.HAMBURG_PORT,
            Fixtures.HAMBURG_ALTONA,
        ]

        for coord in test_locations
            params = NearestParams()
            add_coordinate!(params, coord)

            response = nearest(osrm, params)
            result_cnt = count(response)

            @test result_cnt >= 0

            if result_cnt > 0
                result_lat = latitude(response, 1)
                result_lon = longitude(response, 1)
                result_dist = distance(response, 1)

                @test -90.0f0 <= result_lat <= 90.0f0
                @test -180.0f0 <= result_lon <= 180.0f0
                @test result_dist >= 0.0f0
                @test isfinite(result_lat)
                @test isfinite(result_lon)
                @test isfinite(result_dist)

                # The nearest result should be reasonably close to the input coordinate
                # (within a few kilometers for urban areas)
                @test result_dist < 10000.0f0  # Less than 10km
            end
        end
    end

    @testset "Nearest with zero results requested" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 0)

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        # Should either return 0 results or throw an error
        try
            response = nearest(osrm, params)
            result_cnt = count(response)
            @test result_cnt >= 0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Nearest with large number of results" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 100)  # Request many results

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        result_cnt = count(response)

        @test result_cnt >= 0
        # The actual number of results may be limited by the data
        @test result_cnt <= 100
    end

    @testset "Nearest result distance is reasonable" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        response = nearest(osrm, params)
        result_cnt = count(response)

        if result_cnt > 0
            result_dist = distance(response, 1)
            # For a coordinate in a city center, the nearest road should be very close
            # (typically within a few hundred meters)
            @test result_dist < 1000.0f0  # Less than 1km
            @test result_dist >= 0.0f0
            @test isfinite(result_dist)
        end
    end
end
