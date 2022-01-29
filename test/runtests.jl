using CosmoReaderBase
using Test
using Unitful

const CRB = CosmoReaderBase

@testset "CosmoReaderBase.jl" begin
    @testset "Conversion" begin
        s = rand()
        a = rand(3)
        su = s * u"m"
        au = a * u"m"
        f = rand()
        u = u"mm"

        @test CRB.convert_by_factor(s, f, u) == s * f * u
        @test CRB.convert_by_factor(s, nothing, u) == s * u
        @test CRB.convert_by_factor(s, f, nothing) == s * f
        @test CRB.convert_by_factor(s, nothing, nothing) == s

        @test CRB.convert_by_factor(a, f, u) == a * f * u
        @test CRB.convert_by_factor(a, nothing, u) == a * u
        @test CRB.convert_by_factor(a, f, nothing) == a * f
        @test CRB.convert_by_factor(a, nothing, nothing) == a

        @test CRB.convert_by_factor(su, f, u) == ustrip(u, su * f)
        @test CRB.convert_by_factor(su, nothing, u) == ustrip(u, su)
        @test_throws MethodError CRB.convert_by_factor(su, f, nothing)
        @test_throws MethodError CRB.convert_by_factor(su, nothing, nothing)

        @test CRB.convert_by_factor(au, f, u) == ustrip.(u, au * f)
        @test CRB.convert_by_factor(au, nothing, u) == ustrip.(u, au)
        @test_throws MethodError CRB.convert_by_factor(au, f, nothing)
        @test_throws MethodError CRB.convert_by_factor(au, nothing, nothing)

        ac = copy(a)
        @test CRB.convert_by_factor!(ac, f, u) == a * f * u
        @test ac == ustrip.(a * f * u)

        ac = copy(a)
        @test CRB.convert_by_factor!(ac, nothing, u) == a * u
        @test ac == ustrip.(a * u)

        ac = copy(a)
        @test CRB.convert_by_factor!(ac, f, nothing) == a * f
        @test ac == a * f

        ac = copy(a)
        @test CRB.convert_by_factor!(ac, nothing, nothing) == a
        @test ac == a


        auc = copy(au)
        @test CRB.convert_by_factor!(auc, f, u) == ustrip.(u, au * f)
        @test ustrip.(auc) == ustrip.(uconvert.(u, au * f))

        auc = copy(au)
        @test CRB.convert_by_factor!(auc, nothing, u) == ustrip.(u, au)
        @test ustrip.(auc) == ustrip.(uconvert.(u, au))

        @test_throws MethodError CRB.convert_by_factor!(au, f, nothing) == a * f
        @test_throws MethodError CRB.convert_by_factor!(au, nothing, nothing) == a * f


        ffunc = par -> 1 / par.h0
        simunits = Dict(
            :a => (nothing, nothing),
            :b => (ffunc, nothing),
            :c => (ffunc, u"mm"),
            :d => (nothing, u"mm"),
        )
        propexp = Dict(:a => 1, :b => -3, :c => 1, :d => -3)
        params = CRB.SnapParams(0.7, 2.5)
        scale = 1 / (1 + params.z)

        @test CRB.convert_sim_to(a, :a, simunits, params; units=:sim, unitful=true) == a

        ac = copy(a)
        CRB.convert_sim_to!(ac, :a, simunits, params; units=:sim, unitful=true)
        @test ac == a

        factor = ffunc(params)
        @test CRB.convert_sim_to(a, :a, simunits, params; units=:comoving, unitful=true) == a
        @test CRB.convert_sim_to(a, :b, simunits, params; units=:comoving, unitful=true) == a * factor
        @test CRB.convert_sim_to(a, :c, simunits, params; units=:comoving, unitful=true) == a * factor * u"mm"
        @test CRB.convert_sim_to(a, :d, simunits, params; units=:comoving, unitful=true) == a * u"mm"
        @test CRB.convert_sim_to(a, :a, simunits, params; units=:comoving) == a
        @test CRB.convert_sim_to(a, :c, simunits, params; units=:comoving) == a * factor
        @test CRB.convert_sim_to(a, :d, simunits, params; units=:comoving) == a
        @test CRB.convert_sim_to(a, :e, simunits, params; units=:comoving) == a

        @test CRB.convert_sim_to(a[1], :a, simunits, params; units=:comoving, unitful=true) == a[1]
        @test CRB.convert_sim_to(a[1], :b, simunits, params; units=:comoving, unitful=true) == a[1] * factor
        @test CRB.convert_sim_to(a[1], :c, simunits, params; units=:comoving, unitful=true) ==
              a[1] * factor * u"mm"
        @test CRB.convert_sim_to(a[1], :d, simunits, params; units=:comoving, unitful=true) == a[1] * u"mm"
        @test CRB.convert_sim_to(a[1], :a, simunits, params; units=:comoving) == a[1]
        @test CRB.convert_sim_to(a[1], :c, simunits, params; units=:comoving) == a[1] * factor
        @test CRB.convert_sim_to(a[1], :d, simunits, params; units=:comoving) == a[1]
        @test CRB.convert_sim_to(a[1], :e, simunits, params; units=:comoving) == a[1]

        for (prop, comov_to_phys) in zip([:a, :b, :c, :d, :e], [scale, scale^-3, scale, scale^-3, 1])
            for unitful in [false, true]
                comov = CRB.convert_sim_to(a, prop, simunits, params; units=:comoving, unitful, propexp)
                phys = CRB.convert_sim_to(a, prop, simunits, params; units=:physical, unitful, propexp)
                @test phys ≈ comov * comov_to_phys

                comov = CRB.convert_sim_to(a[1], prop, simunits, params; units=:comoving, unitful, propexp)
                phys = CRB.convert_sim_to(a[1], prop, simunits, params; units=:physical, unitful, propexp)
                @test phys ≈ comov * comov_to_phys

                ac = copy(a)
                comov = CRB.convert_sim_to!(ac, prop, simunits, params; units=:comoving, unitful, propexp)
                @test comov === ac || reinterpret(Float64, comov) === ac

                ac = copy(a)
                phys = CRB.convert_sim_to!(ac, prop, simunits, params; units=:physical, unitful, propexp)
                @test phys === ac || reinterpret(Float64, phys) === ac

                @test phys ≈ comov * comov_to_phys
            end
        end

        for prop in [:a, :b, :c, :d, :e]
            for units in [:physical, :comoving, :sim]
                for unitful in [false, true]
                    val_units = CRB.convert_sim_to(a[1], prop, simunits, params; units, unitful, propexp)
                    val_sim = CRB.convert_to_sim(val_units, prop, simunits, params; units, propexp)
                    @test val_sim ≈ a[1]

                    val_units = CRB.convert_sim_to(a, prop, simunits, params; units, unitful, propexp)
                    val_sim = CRB.convert_to_sim(val_units, prop, simunits, params; units, propexp)
                    @test val_sim ≈ a

                    ac = copy(a)
                    val_units = CRB.convert_sim_to!(ac, prop, simunits, params; units, unitful, propexp)
                    val_sim = CRB.convert_to_sim!(val_units, prop, simunits, params; units, propexp)
                    @test val_sim ≈ a
                    @test val_sim === ac

                    if unitful && units !== :sim && !isnothing(get(simunits, prop, (nothing, nothing))[2])
                        val_units = CRB.convert_sim_to(a[1], prop, simunits, params; units, unitful, propexp)
                        val_units = uconvert.(u"m", val_units)
                        val_sim = CRB.convert_to_sim(val_units, prop, simunits, params; units, propexp)
                        @test val_sim ≈ a[1]

                        val_units = CRB.convert_sim_to(a, prop, simunits, params; units, unitful, propexp)
                        val_units = uconvert.(u"m", val_units)
                        val_sim = CRB.convert_to_sim(val_units, prop, simunits, params; units, propexp)
                        @test val_sim ≈ a

                        ac = copy(a)
                        val_units = CRB.convert_sim_to!(ac, prop, simunits, params; units, unitful, propexp)
                        val_units = uconvert.(u"m", val_units)
                        val_sim = CRB.convert_to_sim!(val_units, prop, simunits, params; units, propexp)
                        @test val_sim ≈ a
                    end
                end
            end
        end
    end
end
