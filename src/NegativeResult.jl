import Base.vcat, Base.+;

export NegativeResult, process, vcat;

mutable struct NegativeResult{A<:AbstractFloat}
	thresholds::Thresholds{A};
	RN::Int; # Real-negative count
	PP::Vector{Int} # Predicted-positive count for each threshold
end

function NegativeResult(thresholds::Thresholds)::NegativeResult
	PP = Vector{Int}(length(thresholds));
	return NegativeResult(thresholds, 0, PP);
end

function process(result::NegativeResult, state::State)::Void
	if length(state.predicted) == 0
		return;
	end
	result.RN = length(state.real);
	predicted = sort(state.predicted);
	THcounter = 1;
	len = length(predicted);
	for i in 1:length(result.thresholds)
		if predicted[1] < result.thresholds[THcounter]
			break;
		end
		result.PP[THcounter] = len;
		THcounter += 1;
	end
	i = 1;
	while i <= (len - 1)
		if THcounter > length(result.thresholds)
			break;
		end
		threshold = result.thresholds[THcounter];
		if predicted[i] < threshold && predicted[i + 1] >= threshold
			result.PP[THcounter] = len - i;
			THcounter += 1;
		else
			i += 1;
		end
	end
	result.PP[THcounter:end] .= 0;
	return;
end

function NegativeResult(thresholds::Thresholds, state::State)::NegativeResult
	result = NegativeResult(thresholds);
	process(result, state);
	return result;
end

function +(result::NegativeResult, state::State)::NegativeResult
	PP = deepcopy(result.PP);
	RN = deepcopy(result.RN);
	process(result, state);
	result.PP .+= PP;
	result.RN += RN;
	return result;
end

function vcat(results::NegativeResult...)::NegativeResult
	RN = mapreduce(x->x.RN, +, results);
	PP = Vector{Int}(length(results[1].thresholds))
	for i in 1:length(PP)
		PP[i] = mapreduce(x->x.PP[i], +, results);
	end
	return NegativeResult(results[1].thresholds, RN, PP);
end
