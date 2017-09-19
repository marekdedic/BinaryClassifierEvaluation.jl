using MLBase;
using StatsBase;
using Plots;

function ROCcurvePartial(;threaded::Bool = false):Bool
	real = rand(0:1, 1024);
	predicted = rand(Float32, 1024);
	rocvec = roc(real, predicted, nquantile(predicted, 100));
	TPRML = map(r->true_positive_rate(r), rocvec);
	FPRML = map(r->false_positive_rate(r), rocvec);
	state = State(predicted, real);
	result = threaded ? evaluate_threaded([state]) : evaluate([state]);
	precisionResult = minimum((TPRML .- TPR(result)) .< 0.01);
	recallResult = minimum((FPRML .- FPR(result)) .< 0.01);

	#plotROCcurve(result);
	#plot!(FPRML, TPRML, label = "MLBase ROC curve");
	return precisionResult && recallResult;
end

function ROCcurveFull(;threaded::Bool = false):Bool
	real1 = rand(0:1, 1024);
	predicted1 = rand(Float32, 1024);
	real2 = zeros(Int, 1024);
	predicted2 = rand(Float32, 1024);
	rocvec = roc(vcat(real1, real2), vcat(predicted1, predicted2), nquantile(predicted1, 100));
	TPRML = map(r->true_positive_rate(r), rocvec);
	FPRML = map(r->false_positive_rate(r), rocvec);
	state1 = State(predicted1, real1);
	state2 = State(predicted2, real2);
	result = threaded ? evaluate_threaded([state1], [state2]) : evaluate([state1], [state2]);
	precisionResult = minimum((TPRML .- TPR(result)) .< 0.01);
	recallResult = minimum((FPRML .- FPR(result)) .< 0.01);

	#plotROCcurve(result);
	#plot!(FPRML, TPRML, label = "MLBase ROC curve");
	return precisionResult && recallResult;
end
