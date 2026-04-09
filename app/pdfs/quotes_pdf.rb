# app/pdfs/quotes_pdf.rb
require "prawn"
require "prawn/table"

class QuotesPdf
  def initialize(company)
    @company = company
    @quotes = company.quotes
      .includes(line_item_dates: :line_items)
      .order(created_at: :desc)
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
      pdf.font_families.update(
        "Inter" => {
          normal: Rails.root.join("app/assets/fonts/Inter-Regular.ttf"),
          bold: Rails.root.join("app/assets/fonts/Inter-Bold.ttf")
        }
      ) rescue nil

      pdf.font("Helvetica")  # fallback

      header(pdf)
      quotes_overview_section(pdf)
      quotes_details(pdf)
    end.render
  end

  private

  # -------------------------------------------------------------------
  # HEADER
  # -------------------------------------------------------------------
  def header(pdf)
    pdf.text "Quotes Report", size: 26, style: :bold, align: :center
    pdf.move_down 5
    pdf.text @company.name, size: 14, align: :center, color: "555555"
    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 25
  end

  # -------------------------------------------------------------------
  # SUMMARY BOX (PROFESSIONAL SAAS LOOK)
  # -------------------------------------------------------------------
  def quotes_overview_section(pdf)
    total_quotes = @quotes.count
    grand_total = @quotes.sum(&:total_price)

    data = [
      ["Summary", ""],
      ["Total Quotes:", total_quotes],
      ["Grand Total:", format_currency(grand_total)]
    ]

    pdf.table(data, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = "F0F0F0"
      column(0).font_style = :bold
      self.cell_style = { borders: [], padding: 8 }
    end

    pdf.move_down 20
  end

  # -------------------------------------------------------------------
  # QUOTES + SECTIONS
  # -------------------------------------------------------------------
  def quotes_details(pdf)
    @quotes.each do |quote|
      pdf.text "Quote ##{quote.name}", size: 18, style: :bold
      pdf.text "Created: #{quote.created_at.strftime("%Y-%m-%d")}", size: 11, color: "666666"
      pdf.move_down 15

      quote.line_item_dates.order(:date).each do |date|
        render_date_section(pdf, date)
      end

      pdf.stroke_horizontal_rule
      pdf.move_down 25
    end
  end

  # -------------------------------------------------------------------
  # EACH DATE SECTION
  # -------------------------------------------------------------------
  def render_date_section(pdf, date)
    pdf.text "Date: #{date.date}", size: 14, style: :bold
    pdf.move_down 8

    table_data = [["Item", "Qty", "Unit Price", "Total"]]
    subtotal = 0

    date.line_items.each do |item|
      total = item.quantity * item.unit_price
      subtotal += total

      table_data << [
        item.name,
        item.quantity.to_s,
        format_currency(item.unit_price),
        format_currency(total)
      ]
    end

    pdf.table(table_data, header: true, width: pdf.bounds.width) do
      row(0).background_color = "DDDDDD"
      row(0).font_style = :bold
      self.row_colors = ["FFFFFF", "F8F8F8"]
      self.cell_style = { borders: [:bottom], padding: 6 }
    end

    pdf.move_down 6
    pdf.text "Subtotal: #{format_currency(subtotal)}",
             size: 12,
             style: :bold,
             align: :right
    pdf.move_down 20
  end

  # -------------------------------------------------------------------
  # CURRENCY FORMATTER
  # -------------------------------------------------------------------
  def format_currency(amount)
    "$%.2f" % amount
  end
end
