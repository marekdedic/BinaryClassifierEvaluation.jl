import ThreadedMap;
export evaluate, evaluate_threaded;

function evaluate{T<:AbstractArray}(mixed::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(mixed))::Result
	result = mapreduce(s->MixedResult(thresholds, s), vcat, mixed);
	return Result(result);
end

function evaluate{T<:AbstractArray, U<:AbstractArray}(mixed::T, negative::U; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(mixed))::Result
	mixedResult = mapreduce(s->MixedResult(thresholds, s), vcat, mixed);
	negativeResult = mapreduce(s->NegativeResult(thresholds, s), vcat, negative);
	return Result(mixedResult, negativeResult);
end

function evaluate_threaded{T<:AbstractArray}(mixed::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(mixed))::Result
	result = ThreadedMap.tmaptreduce(s->MixedResult(thresholds, s), vcat, mixed);
	return Result(result);
end

function evaluate_threaded{T<:AbstractArray, U<:AbstractArray}(mixed::T, negative::U; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(mixed))::Result
	mixedResult = ThreadedMap.tmaptreduce(s->MixedResult(thresholds, s), vcat, mixed);
	negativeResult = ThreadedMap.tmaptreduce(s->NegativeResult(thresholds, s), vcat, negative);
	return Result(mixedResult, negativeResult);
end
