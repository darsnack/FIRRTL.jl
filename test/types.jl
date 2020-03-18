@testset "Types" begin
    @testset "Ground Types" begin
        @test ispassive(Clock()) == true
        @test ispassive(UInteger()) == true
        @test ispassive(SInteger()) == true
        @test ispassive(Analog()) == true
        constructors = [Clock, () -> UInteger(rand(UInt)), () -> SInteger(rand(UInt)), () -> Analog(rand(UInt))]
        @testset for (x, y) in Base.product(constructors, constructors)
            if x == y
                @test (x() == y()) == true
                @test (x() ≈ y()) == true
            else
                @test (x() == y()) == false
                @test (x() ≈ y()) == false
            end
        end
    end

    @testset "Vector Types" begin
        @test ispassive([Clock(), Clock()]) == true
        @test ([Clock(), Clock()] == [Clock(), Clock()]) == true
        @test ([Clock(), Clock()] == [Clock(), UInteger()]) == false
        @test ([Clock(), Clock()] ≈ [Clock(), Clock()]) == true
        @test ([Clock(), Clock()] ≈ [Clock(), UInteger()]) == false
    end

    @testset "Bundle Types" begin
        x = Bundle([:a => UInteger(), :b => UInteger()])
        y = Bundle([:a => UInteger(), :b => UInteger()])
        w = Bundle([:a => (UInteger(), true), :b => (UInteger(), false)])
        z = Bundle([:a => SInteger(), :b => UInteger()])
        q = Bundle([:b => UInteger(), :a => UInteger()])
        @test ispassive(x) == true
        @test (x == y) == true
        @test (x == w) == false
        @test (x == z) == false
        @test (x ≈ q) == true
        @test (x ≈ z) == false
    end
end