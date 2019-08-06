using BinaryClassifierEvaluation;
using Test;

using MLBase;

include("PRcurve.jl");
include("ROCcurve.jl");

@testset "All" begin 
	@testset "PR curve" begin
		@testset "Partial PR curve" begin
			for i in 1:10000
				@test PRcurvePartial();
			end
		end
		@testset "Full PR curve" begin
			for i in 1:10000
				@test PRcurveFull();
			end
		end
	end
	@testset "ROC curve" begin
		@testset "Partial ROC curve" begin
			for i in 1:10000
				@test ROCcurvePartial();
			end
		end
		@testset "Full ROC curve" begin
			for i in 1:10000
				@test ROCcurveFull();
			end
		end
	end
end
