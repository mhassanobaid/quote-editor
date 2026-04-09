class CompanyQuotePdf
  require "prawn"
  require "prawn/table"

  def initialize(company)
    @company = company
    @quotes = company.quotes.includes(line_item_dates: :line_items)
  end

  def call
    Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
      header(pdf)
      summary(pdf)
      pdf.move_down 20

      @quotes.each do |quote|
        quote_section(pdf, quote)
        pdf.move_down 20
      end
    end
  end

  private

  # ---------------- HEADER ----------------
  def header(pdf)
    pdf.text @company.name, size: 24, style: :bold
    pdf.move_down 10
    pdf.stroke_horizontal_rule
  end

  # ---------------- SUMMARY ----------------
  def summary(pdf)
    total_quotes = @quotes.count
    grand_total = calculate_grand_total

    pdf.move_down 10
    pdf.text "Total Quotes: #{total_quotes}", size: 12
    pdf.text "Grand Total: #{format_currency(grand_total)}", size: 12, style: :bold
  end

  # ---------------- QUOTE SECTION ----------------
  def quote_section(pdf, quote)
    pdf.move_down 15
    pdf.text "Quote: #{quote.name}", size: 16, style: :bold

    table_data = build_table_data(quote)

    pdf.table(table_data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = "EEEEEE"
      cells.padding = 8
      cells.size = 10
    end

    subtotal = calculate_quote_total(quote)

    pdf.move_down 5
    pdf.text "Subtotal: #{format_currency(subtotal)}", align: :right, style: :bold
  end

  # ---------------- TABLE DATA ----------------
  def build_table_data(quote)
    data = [["Date", "Item", "Description", "Qty", "Unit Price", "Total"]]

    quote.line_item_dates.each do |date|
      date.line_items.each do |item|
        data << [
          date.date.to_s,
          item.name,
          item.description,
          item.quantity,
          format_currency(item.unit_price),
          format_currency(item.quantity * item.unit_price)
        ]
      end
    end

    data
  end

  # ---------------- CALCULATIONS ----------------
  def calculate_quote_total(quote)
    quote.line_item_dates.sum do |date|
      date.line_items.sum do |item|
        item.quantity * item.unit_price
      end
    end
  end

  def calculate_grand_total
    @quotes.sum { |quote| calculate_quote_total(quote) }
  end

  # ---------------- HELPERS ----------------
  def format_currency(amount)
    "$#{'%.2f' % amount}"
  end
end
