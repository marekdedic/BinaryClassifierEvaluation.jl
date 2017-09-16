import Base.vcat;

export State, vcat;

struct State{A<:AbstractFloat}
	predicted::Vector{A};
	real::Vector{Int};
end

function vcat(states::State...)::State
	return State(mapreduce(x->x.predicted, vcat, states), mapreduce(x->x.real, vcat, states));
end
