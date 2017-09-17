using BinaryClassifierEvaluation
using Base.Test

include("PRcurve.jl");

@testset "All" begin 
	@testset "PR curve" begin
		@testset "Partial PR curve" begin
			for i in 1:25000
				@test PRcurvePartial();
			end
		end
	end
end
