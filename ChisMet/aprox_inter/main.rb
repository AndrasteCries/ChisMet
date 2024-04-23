require 'gtk3'

class LagrangeInterpolation
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
    polynomial = ""
    @x_values.each_with_index do |xi, i|
      term = @y_values[i].to_s
      @x_values.each_with_index do |xj, j|
        next if i == j

        term = "(x - #{xj}) * #{term} / (#{xi} - #{xj})"
      end
      polynomial += "+ #{term}" unless polynomial.empty?
      polynomial = term if polynomial.empty?
    end
    "L(x) = #{polynomial}"
  end
end

x_values = [3, 4, 5, 6, 7]
y_values = [2.5 * 24, 3.6, -0.8, -1.9, -1.1]

lagrange = LagrangeInterpolation.new(x_values, y_values)

app = Gtk::Application.new('org.gtk.example', :flags_none)

app.signal_connect('activate') do |application|
  window = Gtk::ApplicationWindow.new(application)
  window.set_title('Interpolation GUI')
  window.set_default_size(300, 200)

  box = Gtk::Box.new(:vertical, 5)
  window.add(box)

  label = Gtk::Label.new(lagrange.lagrange_polynomial)
  box.pack_start(label, expand: false, fill: false, padding: 5)

  entry = Gtk::Entry.new
  box.pack_start(entry, expand: false, fill: false, padding: 5)

  button = Gtk::Button.new(label: 'Calculate')
  box.pack_start(button, expand: false, fill: false, padding: 5)

  result_label = Gtk::Label.new
  box.pack_start(result_label, expand: false, fill: false, padding: 5)

  button.signal_connect('clicked') do
    x = entry.text.to_f
    result = lagrange.interpolate(x)
    result_label.text = "Interpolated y for x = #{x}: #{result}"
  end

  window.show_all
end

app.run([])
