require 'matrix'

def iteration_method(matrix, b, initial_guess, tolerance)
  n = matrix.size
  x = initial_guess.clone
  k = 0
  while true
    x_new = []

    n.times do |i|
      sum = 0.0

      n.times do |j|
        next if i == j

        sum += matrix[i][j] * x[j]
      end

      x_new[i] = (b[i] - sum) / matrix[i][i]
    end

    max_err = max_error(x, x_new)
    break if max_err < tolerance

    x = x_new

    puts "Error iteration = #{k}: #{max_err} \n"
    k += 1
    puts x.map { |q| format('%.5f', q) }.join(', ')
  end
  x
end


def max_error(x, x_new)
  errors = x.each_with_index.map { |xi, i| (xi - x_new[i]).abs }
  errors.max
end

def calculate_error(matrix, solution, answer)
  rows = matrix.length
  cols = matrix[0].length

  errors = []

  (0..rows - 1).each do |row|
    row_answer = 0

    (0..cols - 1).each do |col|
      row_answer += matrix[row][col] * solution[col]
    end
    error = (answer[row] - row_answer)
    errors << error
  end

  errors
end

def check_convergence(matrix)
  n = matrix.size
  diag_element = 0
  n.times do |i|
    sum_of_non_diag = 0
    n.times do |j|
      if i == j
        diag_element = matrix[i][j]
      else
        sum_of_non_diag += matrix[i][j].abs
      end
    end
    unless diag_element.abs > sum_of_non_diag
      puts "Error"
      return false
    end
  end
  true
end



def calculate_determinant(matrix)
  raise "Matrix is not 4x4" unless matrix.size == 4 && matrix.all? { |row| row.size == 4 }

  Matrix[*matrix].det
end

m = 30

matrix = [
  [5.0, 1.0, -1.0, 1.0],
  [1.0, -4.0, 1.0, -1.0],
  [-1.0, 1.0, 4.0, 1.0],
  [1.0, 2.0, 1.0, -5.0]
]

b = [3.0 * m, m - 6.0, 15.0 - m, m + 2.0]

initial_guess = [0.7 * m, 1, 2, 0.5]

tolerance = 0.0005

determinant = calculate_determinant(matrix)
puts determinant
if determinant > 0 && check_convergence(matrix)
  solution = iteration_method(matrix, b, initial_guess, tolerance)

  puts "Розв'язок системи рівнянь:"
  puts solution.map { |x| format('%.5f', x) }.join(', ')

  error = calculate_error(matrix, solution, b)
  puts "Загальна помилка: #{error}"
end
