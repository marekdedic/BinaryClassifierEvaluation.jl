import Base.size, Base.getindex;
import StatsBase;

export Thresholds;

struct Thresholds{A<:AbstractFloat} <: AbstractVector{A}
	thresholds::Vector{A};
end

function Thresholds{T<:AbstractFloat}(states::Vector{State{T}}; thresholdCount::Int = 100)::Thresholds
	return Thresholds(StatsBase.nquantile(mapreduce(x->x.predicted, vcat, states), thresholdCount));
end

function size(t::Thresholds)::Tuple
	return size(t.thresholds);
end

function getindex(t::Thresholds, i::Int)
	return getindex(t.thresholds, i);
end
