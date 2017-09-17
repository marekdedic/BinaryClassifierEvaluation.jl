using MLBase;
using StatsBase;
using Plots;

function PRcurvePartial()::Bool
	real = rand(0:1, 1024);
	predicted = rand(Float32, 1024);
	rocvec = roc(real, predicted, nquantile(predicted, 100));
	precisionML = map(r->precision(r), rocvec);
	recallML = map(r->recall(r), rocvec);
	state = State(predicted, real);
	result = Result([state]);
	precisionResult = minimum((precisionML .- precision(result)) .< 0.01);
	recallResult = minimum((recallML .- recall(result)) .< 0.01);

	#plotPRcurve(result);
	#plot!(recallML, precisionML, label = "MLBase PR curve");
	return precisionResult && recallResult;
end
