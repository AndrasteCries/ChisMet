def cubic_equation(x)
  return -1.1 * x**3 - 1.5 * x**2 + 0.4 * x - 0.6
  #return (x**3 - 2.8 * x**2 - 6.2 * x + 3.7)
end

def cubic_equation_solver(a, b, epsilon)
  c = (a + b) / 2.0

  while ((b - a).abs >= epsilon)
    if cubic_equation(c).abs < epsilon
      break
    end

    if cubic_equation(c) * cubic_equation(a) < 0
      b = c
    else
      a = c
    end

    c = (a + b) / 2.0
  end

  return c
end

def find_sign_change_intervals(range_start, range_end, step)
  intervals = []
  previous_value = cubic_equation(range_start)

  (range_start..range_end).step(step) do |x|

    current_value = cubic_equation(x)
    # puts "Step: #{x} result: #{current_value}"
    if current_value * previous_value < 0
      intervals << [x - step, x]
    end

    previous_value = current_value
  end

  return intervals
end

a = -10.0
b = 10.0
epsilon = 10**-4

intervals = find_sign_change_intervals(a, b, 0.1)
puts "Intervals where the function changes sign:"
intervals.each do |interval|
  puts "[#{interval[0].round(2)}, #{interval[1].round(2)}]"
  root = cubic_equation_solver(interval[0], interval[1], epsilon)
  puts "Root: #{root}"
  puts "Error = #{sprintf("%.10f", cubic_equation(root))}"
end
