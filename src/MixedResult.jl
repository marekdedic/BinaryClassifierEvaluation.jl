import Base.vcat, Base.+;

export MixedResult, evaluate, vcat;

mutable struct MixedResult{A<:AbstractFloat}
	thresholds::Thresholds{A};
	RP::Int; # Real-positive count
	RN::Int; # Real-negative count
	PP::Vector{Int}; # Predicted-postive count for each threshold
	TP::Vector{Int}; # True-positive count for each threshold
end

function MixedResult(thresholds::Thresholds)::MixedResult
	PP = Vector{Int}(length(thresholds));
	TP = Vector{Int}(length(thresholds));
	return MixedResult(thresholds, 0, 0, PP, TP);
end

function evaluate(result::MixedResult, state::State)::Void
	if length(state.predicted) == 0
		return;
	end
	perm = sortperm(state.predicted);
	predicted = state.predicted[perm];
	real = state.real[perm];
	result.RP = countnz(real .== 1);
	result.RN = countnz(real .== 0);
	TPcounter = result.RP;
	THcounter = 1;
	len = length(predicted);
	for i in 1:length(result.thresholds)
		if predicted[1] < result.thresholds[THcounter]
			break;
		end
		result.TP[THcounter] = TPcounter;
		result.PP[THcounter] = len;
		THcounter += 1;
	end
	if real[1] == 1
		TPcounter -= 1;
	end
	i = 1;
	while i <= (len - 1)
		if THcounter > length(result.thresholds)
			break;
		end
		threshold = result.thresholds[THcounter];
		if (predicted[i] < threshold && predicted[i + 1] >= threshold)
			result.PP[THcounter] = len - i;
			result.TP[THcounter] = TPcounter;
			THcounter += 1;
		else
			if real[i + 1] == 1
				TPcounter -= 1;
			end
			i += 1;
		end
	end
	result.PP[THcounter:end] .= 0;
	result.TP[THcounter:end] .= 0;
	return;
end

function MixedResult(thresholds::Thresholds, state::State)::MixedResult
	result = MixedResult(thresholds);
	evaluate(result, state);
	return result;
end

function +(result::MixedResult, state::State)::MixedResult
	RP = deepcopy(result.RP);
	RN = deepcopy(result.RN);
	PP = deepcopy(result.PP);
	TP = deepcopy(result.TP);
	evaluate(result, state);
	result.RP += RP;
	result.RN += RN;
	result.PP .+= PP;
	result.TP .+= TP;
	return result;
end

function vcat(results::MixedResult...)::MixedResult
	len = length(results[1].thresholds);
	RP = mapreduce(x->x.RP, +, results);
	RN = mapreduce(x->x.RN, +, results);
	TP = Vector{Int}(len);
	PP = Vector{Int}(len);
	for i in 1:len
		PP[i] = mapreduce(x->x.PP[i], +, results);
		TP[i] = mapreduce(x->x.TP[i], +, results);
	end
	return MixedResult(results[1].thresholds, RP, RN, PP, TP);
end
