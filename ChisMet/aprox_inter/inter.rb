require 'rational'

def lagrange_interpolation(x_values, y_values)
  n = x_values.length
  interpolated_function = lambda do |x|
    interpolated_value = 0
    n.times do |i|
      term = y_values[i].to_r
      n.times do |j|
        next if i == j
        term *= (x - x_values[j]).to_r / (x_values[i] - x_values[j]).to_r
      end
      interpolated_value += term
    end
    interpolated_value
  end
  interpolated_function
end

# Функция для генерации полинома в более традиционной форме
def generate_polynomial(interpolated_function, x_values)
  polynomial = ""
  x_values.each_with_index do |x, i|
    coefficient = interpolated_function.call(x)
    polynomial += format("(%s) * x^%d", coefficient.to_s, x_values.length - 1 - i)
    polynomial += " + " unless i == x_values.length - 1
  end
  polynomial
end

# Пример использования:
x_values = [-4, -3, -2, -1, 0]
y_values = [-2, 0, 1, -1, -3]

interpolated_function = lagrange_interpolation(x_values, y_values)

# Проверка значений
puts "Interpolated value at x = 2.5: #{interpolated_function.call(2.5)}"
puts "Interpolated value at x = 3.5: #{interpolated_function.call(3.5)}"

# Генерация полинома в более традиционной форме
polynomial = generate_polynomial(interpolated_function, x_values)
puts "Polynomial: #{polynomial}"
