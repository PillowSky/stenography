function dct(signal) {
	var N = signal.length;
	var PI_N = Math.PI / N;
	var coeff = new Array(N);

	for (var k = 0; k < N; k++) {
		var sum = 0;
		var PI_N_K = PI_N * k;
		for (var n = 0; n < N; n++) {
			sum += signal[n] * Math.cos(PI_N_K * (n + 0.5));
		}
		coeff[k] = sum;
	}

	return coeff;
}

function ict(signal) {
	var N = signal.length;
	var PI_N = Math.PI / N;
	var signal_0_5 = 0.5 * signal[0];
	var coeff = new Array(N);

	for (var k = 0; k < N; k++) {
		var sum = signal_0_5;
		var PI_N_K = PI_N * (k + 0.5);
		for (var n = 1; n < N; n++) {
			sum += signal[n] * Math.cos(PI_N_K * n);
		}
		coeff[k] = sum * 2 / N;
	}

	return coeff;
}

function xct2(signal, width, height, fn) {
	var coeff = new Array(width * height * 4);
	console.log(coeff.length);

	for (var row = 0; row < height; row++) {
		for (var color = 0; color < 4; color++) {
			var channel = new Array(width);
			for (var col = 0; col < width; col++) {
				channel[col] = signal[(row * width + col) * 4 + color];
			}
			var freq = fn(channel);
			for (var col = 0; col < width; col++) {
				coeff[(row * width + col) * 4 + color] = freq[col];
			}
		}
	}

	for (var col = 0; col < width; col++) {
		for (var color = 0; color < 4; color++) {
			var channel = new Array(height);
			for (var row = 0; row < height; row++) {
				channel[row] = coeff[(row * width + col) * 4 + color];
			}
			var freq = fn(channel);
			for (var row = 0; row < height; row++) {
				coeff[(row * width + col) * 4 + color] = freq[row];
			}
		}
	}

	return coeff;
}

function dct2(signal, width, height) {
	return xct2(signal, width, height, dct);
}

function ict2(signal, width, height) {
	return xct2(signal, width, height, ict);
}

module.exports.dct = dct;
module.exports.ict = ict;
module.exports.dct2 = dct2;
module.exports.ict2 = ict2;
