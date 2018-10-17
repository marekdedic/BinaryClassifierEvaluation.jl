import ThreadedMap;
export evaluate, evaluate_threaded;

function evaluate(states::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(states))::Result where T<:AbstractArray
	return mapreduce(s->Result(thresholds, s), vcat, states);
end

function evaluate(mixedStates::T, negativeStates::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(mixedStates))::Result where T<:AbstractArray
	return mapreduce(s->Result(thresholds, s), vcat, vcat(mixedStates, negativeStates));
end

function evaluate_threaded(states::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(states))::Result where T<:AbstractArray
	return ThreadedMap.tmaptreduce(s->Result(thresholds, s), vcat, states);
end

function evaluate_threaded(mixedStates::T, negativeStates::T; thresholdCount::Int = 100, thresholds::Thresholds = Thresholds(mixedStates))::Result where T<:AbstractArray
	return ThreadedMap.tmaptreduce(s->Result(thresholds, s), vcat, vcat(mixedStates, negativeStates));
end
