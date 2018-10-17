import Base.size, Base.getindex;
import Statistics.quantile;

export Thresholds;

struct Thresholds{A<:AbstractFloat} <: AbstractVector{A}
	thresholds::Vector{A};
end

function Thresholds(states::Vector{State{T}}; thresholdCount::Int = 100)::Thresholds where T<:AbstractFloat
	return Thresholds(quantile(mapreduce(x->x.predicted, vcat, states), (0:thresholdCount)/thresholdCount));
end

function size(t::Thresholds)::Tuple
	return size(t.thresholds);
end

function getindex(t::Thresholds, i::Int)
	return getindex(t.thresholds, i);
end
