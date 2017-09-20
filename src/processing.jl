function process_negative(result::Result, state::State)
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

function process_mixed(result::Result, state::State)
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
