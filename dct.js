module.exports.dct = function(signal) {
	var N = signal.length;
	var coeff = new Array(N);

	for (var i = 0; i < N; i++) {
		coeff[i] = signal.map(function(value, index) {
			return value * Math.cos(Math.PI / N * (index + 0.5) * i);
		}).reduce(function(sum, now){
			return sum + now;
		}, 0);
	}

	return coeff;
};

module.exports.ict = function(signal) {
	var N = signal.length;

	var signal_0_5 = 0.5 * signal[0];
	var signal_slice = signal.slice(1);
	var coeff = new Array(N);

	for (var i = 0; i < N; i++) {
		coeff[i] = 2.0 / N * (signal_0_5 + signal_slice.map(function(value, index) {
					return value * Math.cos(Math.PI / N * (index + 1) *  (i + 0.5));
			}).reduce(function(sum, now){
				return sum + now;
			}, 0)
		);
	}
	return coeff;
};
