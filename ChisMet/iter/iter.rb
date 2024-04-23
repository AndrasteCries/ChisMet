require 'gtk3'

class LagrangeInterpolation
  attr_reader :x_values, :y_values

  def initialize(x_values, y_values)
    raise ArgumentError, 'Number of x values must be equal to number of y values' unless x_values.length == y_values.length

    @x_values = x_values
    @y_values = y_values
  end

  def interpolate(x)
    result = 0
    @x_values.each_with_index do |xi, i|
      interpolation_term = @y_values[i]
      @x_values.each_with_index do |xj, j|
        next if i == j

        interpolation_term *= (x - xj) / (xi - xj).to_f
      end
      result += interpolation_term
    end
    result
  end

  def lagrange_polynomial
    polynomial = []
    @x_values.each_with_index do |xi, i|
      numerator = ""
      denominator = ""
      @x_values.each_with_index do |xj, j|
        next if i == j

        numerator += "(x - #{xj}) * "
        denominator += "(#{xi} - #{xj}) * "
      end
      term = "#{@y_values[i]} * (#{numerator[0...-3]} / #{denominator[0...-3]})"
      polynomial << term
    end
    "L(x) = #{polynomial.join("\n          + ")}"
  end
end

def interpolate_and_display(lagrange, x_value, result_label)
  interpolated_y = lagrange.interpolate(x_value)
  result_label.text = "Interpolated y for x = #{x_value}: #{interpolated_y}"
end

def read_values_from_file(filename)
  x_values = []
  y_values = []

  File.open(filename, 'r') do |file|
    while (line = file.gets)
      values = line.split(',').map(&:to_f)
      x_values << values.shift
      y_values << values.shift
    end
  end

  [x_values, y_values]
end

app = Gtk::Application.new('org.gtk.example', :flags_none)

app.signal_connect('activate') do |application|
  window = Gtk::ApplicationWindow.new(application)
  window.set_title('Interpolation GUI')
  window.set_default_size(400, 300)

  box = Gtk::Box.new(:vertical, 5)
  window.add(box)

  x_label = Gtk::Label.new('x Values:')
  box.pack_start(x_label, expand: false, fill: false, padding: 5)

  x_entry = Gtk::Entry.new
  box.pack_start(x_entry, expand: false, fill: false, padding: 5)

  y_label = Gtk::Label.new('y Values:')
  box.pack_start(y_label, expand: false, fill: false, padding: 5)

  y_entry = Gtk::Entry.new
  box.pack_start(y_entry, expand: false, fill: false, padding: 5)

  load_button = Gtk::Button.new(label: 'Load from File')
  box.pack_start(load_button, expand: false, fill: false, padding: 5)

  interpolate_button = Gtk::Button.new(label: 'Interpolate')
  box.pack_start(interpolate_button, expand: false, fill: false, padding: 5)

  x_to_interpolate_label = Gtk::Label.new('X to interpolate:')
  box.pack_start(x_to_interpolate_label, expand: false, fill: false, padding: 5)

  x_to_interpolate_entry = Gtk::Entry.new
  box.pack_start(x_to_interpolate_entry, expand: false, fill: false, padding: 5)

  result_label = Gtk::Label.new
  box.pack_start(result_label, expand: false, fill: false, padding: 5)

  polynomial_label = Gtk::Label.new
  box.pack_start(polynomial_label, expand: false, fill: false, padding: 5)

  load_button.signal_connect('clicked') do
    filename = "data.txt"
    if File.exist?(filename)
      x_values, y_values = read_values_from_file(filename)
      x_entry.text = x_values.join(', ')
      y_entry.text = y_values.join(', ')
    else
      Gtk::MessageDialog.new(parent: window, flags: :modal, type: :error, buttons: :close, message: "File #{filename} not found").run
    end
  end

  interpolate_button.signal_connect('clicked') do
    x_values = x_entry.text.split(',').map(&:to_f)
    y_values = y_entry.text.split(',').map(&:to_f)

    begin
      lagrange = LagrangeInterpolation.new(x_values, y_values)
      interpolate_and_display(lagrange, x_to_interpolate_entry.text.to_f, result_label)
      polynomial_label.text = lagrange.lagrange_polynomial
    rescue ArgumentError => e
      result_label.text = "Error: #{e.message}"
      polynomial_label.text = ""
    end
  end

  window.show_all
end

app.run([])
