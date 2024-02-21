require 'gtk3'

class EquationSolverApp
  def initialize
    @equation_entries = []

    @app = Gtk::Application.new('org.example.EquationSolver', :flags_none)

    @app.signal_connect(:activate) do
      build_ui
    end

    @app.run([$0] + ARGV)
  end

  def build_ui
    window = Gtk::ApplicationWindow.new(@app)
    window.set_title('Equation Solver')
    window.set_default_size(600, 300)

    grid = Gtk::Grid.new
    grid.margin = 10
    grid.row_spacing = 5
    grid.column_spacing = 10

    3.times do |row|
      %w[A A A B].each_with_index do |variable, col|
        variable_label = Gtk::Label.new("#{variable}#{row+1}#{col+1}:")
        grid.attach(variable_label, col * 2, row, 1, 1)

        entry = Gtk::Entry.new
        @equation_entries << entry
        grid.attach(entry, col * 2 + 1, row, 1, 1)
      end
    end
    load_button = Gtk::Button.new(label: 'Load from File')
    load_button.signal_connect('clicked') { load_equations_from_file }
    grid.attach(load_button, 0, 6, 8, 1)
    solve_button = Gtk::Button.new(label: 'Solve')
    solve_button.signal_connect('clicked') { solve_equations }
    grid.attach(solve_button, 0, 4, 8, 1)

    @result_label = Gtk::Label.new
    grid.attach(@result_label, 0, 5, 8, 1)

    window.add(grid)
    window.show_all
  end

  def calculate_determinant(matrix)

    a, b, c = matrix[0][0], matrix[0][1], matrix[0][2]
    d, e, f = matrix[1][0], matrix[1][1], matrix[1][2]
    g, h, i = matrix[2][0], matrix[2][1], matrix[2][2]

    determinant = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)

    determinant
  end

  def calculate_error(matrix, solution)
    rows = matrix.length
    cols = matrix[0].length - 1

    errors = []

    (0..rows - 1).each do |row|
      answer = 0
      (0..cols - 1).each do |col|
        answer += matrix[row][col] * solution[col]
      end
      puts matrix[row][cols]
      puts answer
      error = matrix[row][cols] - answer
      errors << error
    end

    errors
  end

  def solve_equations
    matrix = []
    @equation_entries.each_slice(4) do |entry_group|
      row_values = entry_group.map { |entry| entry.text.to_f }
      matrix << row_values
    end

    if calculate_determinant(matrix) != 0
      solution = solve_system_of_equations(matrix)

      matrix = []
      @equation_entries.each_slice(4) do |entry_group|
        row_values = entry_group.map { |entry| entry.text.to_f }
        matrix << row_values
      end

      error = calculate_error(matrix, solution)

      @result_label.text = "Solution: #{solution.join(', ')}\nError: #{error}\n"
    else
      @result_label.text = "Determinant -"
    end

  end

  def solve_system_of_equations(matrix)
    rows = matrix.length
    cols = matrix[0].length - 1
    (0..cols - 1).each do |col|
      (col + 1..rows - 1).each do |row|
        factor = matrix[row][col].to_f / matrix[col][col]
        (col..cols).each do |i|
          matrix[row][i] -= factor * matrix[col][i]
        end
      end
    end

    (cols - 1).downto(0) do |col|
      (col + 1..cols).each do |i|
        matrix[col][i] /= matrix[col][col].to_f
      end
      matrix[col][col] = 1

      (0..col - 1).each do |row|
        factor = matrix[row][col]
        (col..cols).each do |i|
          matrix[row][i] -= factor * matrix[col][i]
        end
      end
    end


    solution = []
    (0..rows - 1).each do |row|
      solution << matrix[row][cols]
    end

    solution
  end

#example
# matrix = [
#   [5.39, -1.24, 2.03, 4.98],
#   [2.03, -1.24, -4.72, 2.42],
#   [3.18, 2.60, -5.67, 3.52]
# ]

def load_equations_from_file
  dialog = Gtk::FileChooserDialog.new(
    title: 'Choose a file',
    parent: @app.active_window,
    action: :open,
    buttons: [[Gtk::Stock::OPEN, :ok], [Gtk::Stock::CANCEL, :cancel]]
  )

  if dialog.run == :ok
    file_path = dialog.filename
    load_equations(file_path)
  end

  dialog.destroy
end

def load_equations(file_path)
  matrix = []

  File.foreach(file_path) do |line|
    equation_values = line.scan(/[-]?\d+(?:\.\d+)?(?:\/\d+)?/).map { |num| eval(num) }
    matrix << equation_values
  end

  fill_entries_from_matrix(matrix)
end


  def fill_entries_from_matrix(matrix)
    @equation_entries.each_with_index do |entry, index|
      row = (index / 4)
      col = (index % 4)
      entry.text = matrix[row][col].to_s
    end
  end
end

EquationSolverApp.new
