import Base.size, Base.getindex;

export Thresholds;

struct Thresholds{A<:AbstractFloat} <: AbstractVector{A}
	thresholds::Vector{A};
end

function Thresholds{T<:AbstractFloat}(states::Vector{State{T}}; thresholdCount::Int = 100)::Thresholds
	return Thresholds(quantile(mapreduce(x->x.predicted, vcat, states), (0:thresholdCount)/thresholdCount));
end

function size(t::Thresholds)::Tuple
	return size(t.thresholds);
end

function getindex(t::Thresholds, i::Int)
	return getindex(t.thresholds, i);
end
