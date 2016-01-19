SALES_TAX = 0.1
IMPORT_TAX = 0.05

class Calculation
  def parse
    file = ('input_file.txt')
    samples = File.readlines(file)
  end

  def prep_input_file
    parse.map do |line|
      line.chomp!
    end
  end

  def characteristics(input)
    parse.map do |x|
      if x.include?("#{input}")
        x.chomp
      end
    end.compact
  end

  def imported_goods
    imported_line_items = characteristics("imported")
  end

  def food_items
    food_line_items = characteristics("chocolate")
  end

  def medical_items
    medical_line_items = characteristics("pills")
  end

  def book_items
    book_line_items = characteristics("book")
  end

  def price_times_quantity(input)
    attributes = input.split
    quantity = attributes[0].to_f
    price = attributes[-1].to_f
    value = price * quantity
    value
  end

  def line_items_and_associated_tax
    output = Hash.new
    import_tax = prep_input_file.map do |line_item|
      if imported_goods.include?(line_item) && (food_items.include?(line_item) || medical_items.include?(line_item) || book_items.include?(line_item))
        value = price_times_quantity(line_item)
        taxes = (value * IMPORT_TAX)
        output[line_item] = round_up(taxes)
      elsif imported_goods.include?(line_item)
        value = price_times_quantity(line_item)
        taxes = (value * IMPORT_TAX + value * SALES_TAX)
        output[line_item] = round_up(taxes)
      elsif food_items.include?(line_item) || medical_items.include?(line_item) || book_items.include?(line_item)
        value = price_times_quantity(line_item)
        taxes = 0
        output[line_item] = round_up(taxes)
      else
        value = price_times_quantity(line_item)
        taxes = (value * SALES_TAX)
        output[line_item] = round_up(taxes)
      end
    end
    output
  end

  def round_up(tax)
    (tax*20).ceil / 20.0
  end

  def tax_for_each_line_item
    line_items_and_associated_tax.map do |line_item, tax|
      tax
    end
  end

  def total_tax
    round_up(tax_for_each_line_item.inject {|sum, n| sum += n})
  end

  def total_tax_formatted_output
    "Sales Tax: #{"%.2f" % total_tax}"
  end

  def output_header
    values = line_items_and_associated_tax.to_a
    header = values[0][0].gsub("Input", "Output")
    header
  end

  def output_values_formatted
    output_body = Array.new
    values = line_items_and_associated_tax.to_a
    values[1..-1].map do |line_item|
      attributes = line_item[0].split
      if attributes[-1].to_f != 0.00
        output_body << line_item[0].gsub(attributes[-3], "#{attributes[-3] + ": "}").sub(" at ", "").gsub(attributes[-1], ("%.2f" % (attributes[-1].to_f + line_item[1]).round(2)).to_s)
      else
        output_body << line_item
      end
    end
    output_body
  end

  def prices_without_tax
    prices = prep_input_file.map do |line_item|
      price_times_quantity(line_item)
    end
  end

  def prices_with_tax
    item_prices = prices_without_tax.inject {|sum, n| sum += n}
    "Total: #{"%.2f" % (item_prices + total_tax)}"
  end

  def output
    puts output_header
    puts output_values_formatted
    puts total_tax_formatted_output
    puts prices_with_tax
  end
end

stuff = Calculation.new
stuff.output
