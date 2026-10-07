import 'dart:math';

/// P(X <= k) for a Poisson(lambda) variable.
double poissonCdf(int k, double lambda) {
  var term = exp(-lambda); // P(X = 0)
  var sum = term;
  for (var i = 1; i <= k; i++) {
    term *= lambda / i;
    sum += term;
  }
  return sum;
}

/// P(X >= k): chance of k or more arrivals in the hour.
double surgeProbability(double lambda, int k) => 1 - poissonCdf(k - 1, lambda);

/// Demo arrivals per hour (lambda), index = hour of day.
/// Illustrative seed values, not measured data.
const hourlyLambda = <double>[
  1, 1, 1, 1, 1, 2, 2, 3, 4, 6, 8, 7, 5, 4, 4, 4, 5, 5, 4, 3, 2, 2, 1, 1
];

const surgeCapacity = 6; // arrivals per hour the desk can clear
const surgeThreshold = 0.65; // above this, pre-arm Trust Mode

class ClaimInputs {
  final bool dateMismatch;
  final double blur; // 0 = sharp scan, 1 = very blurry
  final double nameDissimilarity; // 0 = identical, 1 = totally different
  final double clerkExpMonths;

  const ClaimInputs({
    required this.dateMismatch,
    required this.blur,
    required this.nameDissimilarity,
    required this.clerkExpMonths,
  });
}

/// Logistic model: p = 1 / (1 + e^-z).
/// Coefficients are seeded guesses, NOT fitted. Re-fit on real rejection data.
double rejectionRisk(ClaimInputs c) {
  final z = -3.0 +
      2.0 * (c.dateMismatch ? 1 : 0) +
      1.5 * c.blur +
      2.5 * c.nameDissimilarity -
      0.02 * c.clerkExpMonths;
  return 1 / (1 + exp(-z));
}