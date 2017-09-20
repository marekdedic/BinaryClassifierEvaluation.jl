import ThreadedMap;
export evaluate, evaluate_threaded;

function evaluate{T<:AbstractArray}(states::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(states))::Result
	return mapreduce(s->Result(thresholds, s), vcat, states);
end

function evaluate{T<:AbstractArray}(mixedStates::T, negativeStates::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(mixedStates))::Result
	return mapreduce(s->Result(thresholds, s), vcat, vcat(mixedStates, negativeStates));
end

function evaluate_threaded{T<:AbstractArray}(states::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(states))::Result
	return ThreadedMap.tmaptreduce(s->Result(thresholds, s), vcat, states);
end

function evaluate_threaded{T<:AbstractArray}(mixedStates::T, negativeStates::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(mixedStates))::Result
	return ThreadedMap.tmaptreduce(s->Result(thresholds, s), vcat, vcat(mixedStates, negativeStates));
end
