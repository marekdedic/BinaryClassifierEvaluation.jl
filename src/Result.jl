export Result;

struct Result{A<:AbstractFloat}
	thresholds::Vector{A};
	RP::Int;
	RN::Int;
	PP::Vector{Int};
	TP::Vector{Int};
end

function Result(result::MixedResult)::Result
	return Result(result.thresholds, result.RP, result.RN, result.PP, result.TP);
end

function Result(mresult::MixedResult, nresult::NegativeResult)::Result
	return Result(mresult.thresholds, mresult.RP, mresult.RN + nresult.RN, mresult.PP .+ nresult.PP, mresult.TP);
end
