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
	result = evaluate([state]);
	precisionResult = minimum((precisionML .- precision(result)) .< 0.01);
	recallResult = minimum((recallML .- recall(result)) .< 0.01);

	#plotPRcurve(result);
	#plot!(recallML, precisionML, label = "MLBase PR curve");
	return precisionResult && recallResult;
end

function PRcurveFull()::Bool
	real1 = rand(0:1, 1024);
	predicted1 = rand(Float32, 1024);
	real2 = zeros(Int, 1024);
	predicted2 = rand(Float32, 1024);
	rocvec = roc(vcat(real1, real2), vcat(predicted1, predicted2), nquantile(predicted1, 100));
	precisionML = map(r->precision(r), rocvec);
	recallML = map(r->recall(r), rocvec);
	state1 = State(predicted1, real1);
	state2 = State(predicted2, real2);
	result = evaluate([state1], [state2]);
	precisionResult = minimum((precisionML .- precision(result)) .< 0.01);
	recallResult = minimum((recallML .- recall(result)) .< 0.01);

	#plotPRcurve(result);
	#plot!(recallML, precisionML, label = "MLBase PR curve");
	return precisionResult && recallResult;
end
