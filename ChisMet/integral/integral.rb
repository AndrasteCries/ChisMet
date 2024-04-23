def f(x)
  return (x**2 + 1.9) / (x**4 + 3.1)
end

# Метод прямокутників
def rectangle_method(a, b, n)
  h = (b - a) / n.to_f
  sum = 0.0
  x = a
  n.times do |i|
    x_i = x + h/2
    sum += f(x_i)
    x += h
  end
  return sum * h
end

# Метод трапецій
def trapezoidal_method(a, b, n)
  h = (b - a) / n.to_f
  sum = (f(a) + f(b)) / 2.0
  x_i = a + h
  (1...n).each do |i|
    sum += f(x_i)
    x_i += h
  end
  return sum * h
end

# Метод Сімпсона
def simpsons_method(a, b, n)
  h = (b - a) / n.to_f
  sum = f(a) + f(b)
  n.times do |i|
    x_i = a + i * h
    sum += i.odd? ? 4 * f(x_i) : 2 * f(x_i)
  end
  return sum * h / 3.0
end

a = 0.0
b = 1.2
n = 10

integral_rect = rectangle_method(a, b, n).abs
integral_trap = trapezoidal_method(a, b, n).abs
integral_simp = simpsons_method(a, b, n).abs

puts "Границі інтегралу: [#{a}, #{b}]"
puts "Метод прямокутників: #{integral_rect}"
puts "Метод трапецій: #{integral_trap}"
puts "Метод Сімпсона: #{integral_simp}"
