import Plots;
import MLBase.precision, MLBase.recall;

export Result, precision, recall, plotPRcurve;

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

# Complete Ctors

function Result{T<:AbstractFloat}(mixed::Vector{State{T}}; thresholdCount::Int = 100)
	thresholds = Thresholds(mixed);
	mixedResultVec = map(s->MixedResult(thresholds, s), mixed);
	mixedResult = vcat(mixedResultVec...);
	return Result(mixedResult);
end

# Quality measures

function precision(result::Result)::Vector
	precision = result.TP ./ result.PP;
	precision[result.PP .== 0] .= 1;
	return precision;
end

function recall(result::Result)::Vector
	return result.TP ./ result.RP;
end

# Plotting

function plotPRcurve{S<:AbstractString, T<:AbstractFloat}(labels::Vector{S}, results::Vector{Result{T}}; title::AbstractString = "")
	lims = (0, 1.05);
	Plots.plot(; xlabel = "Recall", ylabel = "Precision", xlims = lims, ylims = lims, title = title)
	pl(label, result) = Plots.plot!(recall(result), precision(result); label = label);
	pl.(labels, results);
	Plots.gui();
end

plotPRcurve(result::Result; title::AbstractString = "") = plotPRcurve(["PR Curve"], [result]; title = title);
