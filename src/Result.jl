import Plots;
import Base.+, Base.vcat;
import MLBase.precision, MLBase.recall;

export Result, +, vcat;
export RP, RN, PP, PN, TP, FP, FN, TN;
export population, prevalence, accuracy, precision, recall, FNR, FPR, specificity, FDR, FOR, NPV, PLR, NLR, DOR, Fscore;
export TPR, sensitivity, fallout, TNR, PPV;
export plotPRcurve, plotFscore, plotROCcurve, plotDETcurve;

mutable struct Result{A<:AbstractFloat}
	thresholds::Thresholds{A};
	RP::Int;
	RN::Int;
	PP::Vector{Int};
	TP::Vector{Int};
end

# Ctors

function Result(thresholds::Thresholds)::Result
	PP = zeros(Int, length(thresholds));
	TP = zeros(Int, length(thresholds));
	return Result(thresholds, 0, 0, PP, TP);
end

function Result(thresholds::Thresholds, state::State)::Result
	result = Result(thresholds);
	process(result, state);
	return result;
end

# Processing

function process(result::Result, state::State)::Nothing
	if maximum(state.real) == 0
		process_negative(result, state);
	else
		process_mixed(result, state);
	end
	return;
end

function +(result::Result, state::State)::Result
	RP = deepcopy(result.RP);
	RN = deepcopy(result.RN);
	PP = deepcopy(result.PP);
	TP = deepcopy(result.TP);
	process(result, state);
	result.RP += RP;
	result.RN += RN;
	result.PP .+= PP;
	result.TP .+= TP;
	return result;
end

function vcat(results::Result...)::Result
	len = length(results[1].thresholds);
	RP = mapreduce(x->x.RP, +, results);
	RN = mapreduce(x->x.RN, +, results);
	TP = Vector{Int}(undef, len);
	PP = Vector{Int}(undef, len);
	for i in 1:len
		PP[i] = mapreduce(x->x.PP[i], +, results);
		TP[i] = mapreduce(x->x.TP[i], +, results);
	end
	return Result(results[1].thresholds, RP, RN, PP, TP);
end

# Values

function RP(result::Result)::Int # Real positives
	return result.RP;
end

function RN(result::Result)::Int # Real negatives
	return result.RN;
end

function PP(result::Result)::Vector # Total positive predictions for each threshold
	return result.PP;
end

function PN(result::Result)::Vector # Total negative predictions for each threshold
	return result.RP + result.RN - result.PP;
end

function TP(result::Result)::Vector # True positives for each threshold
	return result.TP;
end

function FP(result::Result)::Vector # False-positives for each threshold
	return result.PP - result.TP;
end

function FN(result::Result)::Vector # False-negatives for each threshold
	return result.RP - result.TP;
end

function TN(result::Result)::Vector # True-negatives for each threshold
	return result.RN + result.TP - result.PP;
end

# Quality measures

function population(result::Result)::Int
	return RP(result) + RN(result);
end

function prevalence(result::Result)::Int
	return RP(result) / population(result);
end

function accuracy(result::Result)::Vector
	return ((2 .* TP(result)) .+ RN(result) .- PP(result)) ./ (RP(result) + RN(result));
end

function precision(result::Result)::Vector
	precision = TP(result) ./ PP(result);
	precision[PP(result) .== 0] .= 1;
	return precision;
end

function recall(result::Result)::Vector
	return TP(result) ./ RP(result);
end

function FNR(result::Result)::Vector # False-negative rate
	return FN(result) ./ RP(result);
end

function FPR(result::Result)::Vector # False-positive rate
	return FP(result) ./ RN(result);
end

function specificity(result::Result)::Vector
	return TN(result) ./ RN(result);
end

function FDR(result::Result)::Vector # False discovery rate
	return FP(result) ./ PP(result);
end

function FOR(result::Result)::Vector # False omission rate
	return FN(result) ./ PN(result);
end

function NPV(result::Result)::Vector # Negative predictive value
	return TN(result) ./ PN(result);
end

function PLR(result::Result)::Vector # Positive likelihood ratio
	return (TP(result) .* RN(result)) ./ (FP(result) .* RP(result));
end

function NLR(result::Result)::Vector # Negative likelihood ratio
	return (FN(result) .* RN(result)) ./ (TN(result) .* RP(result));
end

function DOR(result::Result)::Vector # Diagnostic odds ratio
	return (TP(result) .* TN(result)) ./ (FP(result) .* FN(result));
end

function Fscore(result::Result; beta::AbstractFloat = 1.0)::Vector
	return (1 + beta^2) .* precision(result) .* recall(result) ./ ((beta^2 * precision(result)) .+ recall(result));
end

# Aliases

TPR(result::Result)::Vector = recall(result); # True-positive rate

sensitivity(result::Result)::Vector = recall(result);

fallout(result::Result)::Vector = FPR(result);

TNR(result::Result)::Vector = specificity(result); # True-negative rate

PPV(result::Result)::Vector = precision(result); # Positive predictive value

# Plotting

function plotPRcurve(labels::Vector{S}, results::Vector{Result{T}}; title::AbstractString = "")::Nothing where {S <: AbstractString, T <: AbstractFloat}
	lims = (0, 1.05);
	Plots.plot(; xlabel = "Recall", ylabel = "Precision", xlims = lims, ylims = lims, title = title)
	pl(label, result) = Plots.plot!(recall(result), precision(result); label = label);
	pl.(labels, results);
	Plots.gui();
	return;
end

plotPRcurve(result::Result; title::AbstractString = "")::Nothing = plotPRcurve(["PR Curve"], [result]; title = title);

function plotFscore(labels::Vector{S}, results::Vector{Result{T}}; beta::AbstractFloat = 1.0, title::AbstractString = "")::Nothing where {S<:AbstractString, T<:AbstractFloat}
	Plots.plot(; xlabel = "Threshold", ylabel = "F" * string(beta) * " score", ylims = (0, 1.05), title = title)
	pl(label, result) = Plots.plot!(result.thresholds, Fscore(result; beta = beta); label = label);
	pl.(labels, curves);
	Plots.gui();
	return;
end

plotFscore(result::Result; beta::AbstractFloat = 1.0, title::AbstractString = "")::Nothing = plotFscore(["F" * string(beta) * " score"], [result]; beta = beta, title = title);

function plotROCcurve(labels::Vector{S}, results::Vector{Result{T}}; log::Bool = false, title::AbstractString = "")::Nothing where {S<:AbstractString, T<:AbstractFloat}
	lims = (0, 1);
	if log
		Plots.plot(0.001:0.001:1, 0.001:0.001:1; linestyle= :dot, label = "", xlabel = "False positive rate", ylabel = "True positive rate", xlims = (0.001, 1), ylims = lims, xscale = :log10, title = title);
	else
		Plots.plot(identity; linestyle= :dot, label = "", xlabel = "False positive rate", ylabel = "True positive rate", xlims = lims, ylims = lims, title = title);
	end
	pl(label, result) = Plots.plot!(FPR(result), TPR(result); label = label);
	pl.(labels, results);
	Plots.gui();
	return;
end

plotROCcurve(result::Result; log::Bool = false, title::AbstractString = "")::Nothing = plotROCcurve(["ROC curve"], [result]; log = log, title = title);

function plotDETcurve(labels::Vector{S}, results::Vector{Result{T}}; title::AbstractString = "")::Nothing where {S<:AbstractString, T<:AbstractFloat}
	qnorm(x) = sqrt(2) * erfinv(2x - 1);
	lims = (qnorm(0.001), qnorm(0.55));
	tickvalues = [0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 40, 50];
	ticks = (qnorm.(tickvalues ./ 100), string.(tickvalues));
	Plots.plot(; xlabel = "False positive rate (%)", ylabel = "False negative rate (%)", xlims = lims, ylims = lims, xticks = ticks, yticks = ticks, aspect_ratio = :equal, title = title);
	pl(label, result) =	Plots.plot!(qnorm.(FPR(result)), qnorm.(FNR(result)); label = label);
	pl.(labels, results);
	Plots.gui();
	return;
end

plotDETcurve(result::Result; title::AbstractString = "")::Nothing = plotDETcurve(["DET Curve"], [result]; title = title);
