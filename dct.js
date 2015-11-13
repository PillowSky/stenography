"use strict";

var dctCosCache = {};
var ictCosCache = {};

function calcDctCos(N) {
	if (dctCosCache[N]) {
		return dctCosCache[N];
	} else {
		var cache = new Array(N * N);
		var PI_N = Math.PI / N;
		for (var k = 0; k < N; k++) {
			var PI_N_K = PI_N * k;
			for (var n = 0; n < N; n++) {
				cache[k * N + n] = Math.cos(PI_N_K * (n + 0.5));
			}
		}
		dctCosCache[N] = cache;
		return cache;
	}
}

function calcIctCos(N) {
	if (ictCosCache[N]) {
		return ictCosCache[N];
	} else {
		var cache = new Array(N * N);
		var PI_N = Math.PI / N;
		for (var k = 0; k < N; k++) {
			var PI_N_K = PI_N * (k + 0.5);
			for (var n = 1; n < N; n++) {
				cache[k * N + n] = Math.cos(PI_N_K * n);
			}
		}
		ictCosCache[N] = cache;
		return cache;
	}
}

function dct(signal) {
	var N = signal.length;
	var cos = calcDctCos(N);
	var coeff = new Array(N);

	for (var k = 0; k < N; k++) {
		var sum = 0;
		for (var n = 0; n < N; n++) {
			sum += signal[n] * cos[k * N + n];
		}
		coeff[k] = sum;
	}

	return coeff;
}

function ict(signal) {
	var N = signal.length;
	var cos = calcIctCos(N);
	var signal_0_5 = 0.5 * signal[0];
	var coeff = new Array(N);

	for (var k = 0; k < N; k++) {
		var sum = signal_0_5;
		for (var n = 1; n < N; n++) {
			sum += signal[n] * cos[k * N + n];
		}
		coeff[k] = sum * 2 / N;
	}

	return coeff;
}

function xct2(signal, width, height, fn) {
	var coeff = new Array(width * height * 4);

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
