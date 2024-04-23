class Polynomial
  attr_accessor :coefficients

  def initialize(coefficients)
    @coefficients = coefficients.reverse
  end

  def to_s
    "Поліном: #{coefficients.map.with_index { |coeff, i| "#{coeff}x^#{i}" }.join(' + ')}"
  end
end
class Approximation
  def least_squares(x, y, degree)
    n = x.size
    matrix = Array.new(degree + 1) { Array.new(degree + 2, 0) }

    (degree + 1).times do |i|
      (degree + 1).times do |j|
        matrix[i][j] = x.zip(x).sum { |xk| xk[0] ** (i + j) }
      end
      matrix[i][-1] = y.zip(x).sum { |yk, xk| yk * (xk ** i) }
    end
    solve_system(matrix)
  end

  private

  def solve_system(matrix)
    n = matrix.size

    (0..n - 2).each do |i|
      ((i + 1)..n - 1).each do |j|
        factor = matrix[j][i] / matrix[i][i]
        (i..n).each { |k| matrix[j][k] -= factor * matrix[i][k] }
      end
    end

    result = Array.new(n, 0)

    (n - 1).downto(0) do |i|
      result[i] = (matrix[i][-1] - (i + 1...n).sum { |j| matrix[i][j] * result[j] }) / matrix[i][i]
    end

    result.reverse
  end
end
x = [3, 4, 5, 6, 7]
y = [2.5 * 24, 3.6, -0.8, -1.9, -1.1]

approximation = Approximation.new
coefficients_linear = approximation.least_squares(x, y, 1)
linear_polynomial = Polynomial.new(coefficients_linear)

coefficients_quadratic = approximation.least_squares(x, y, 2)
quadratic_polynomial = Polynomial.new(coefficients_quadratic)

puts "Коефіцієнти полінома першого ступеня: #{coefficients_linear}"
puts "Коефіцієнти полінома другого ступеня: #{coefficients_quadratic}"

error_linear = x.zip(y).sum { |xi, yi| (yi - linear_polynomial.evaluate(xi)).abs }
error_quadratic = x.zip(y).sum { |xi, yi| (yi - quadratic_polynomial.evaluate(xi)).abs }

puts "Похибка апроксимації поліномом першого ступеня: #{error_linear}"
puts "Похибка апроксимації поліномом другого ступеня: #{error_quadratic}"
