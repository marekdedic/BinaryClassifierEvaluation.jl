import StatsBase;

export Thresholds;

struct Thresholds{A<:AbstractFloat}
	thresholds::Vector{A};
end

function Thresholds{T<:AbstractFloat}(states::Vector{State{T}}; thresholdCount::Int = 100)::Thresholds
	return Thresholds(StatsBase.nquantile(mapreduce(x->x.predicted, vcat, states), thresholdCount));
end
