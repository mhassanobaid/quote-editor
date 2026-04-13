class LineItemDatesController < ApplicationController
  before_action :set_quote
  before_action :set_line_item_date, only: [:edit, :update, :destroy]

  def new
    @line_item_date = @quote.line_item_dates.build
    authorize @line_item_date
  end

  def create
    @line_item_date = @quote.line_item_dates.build(line_item_date_params)
    authorize @line_item_date

    if @line_item_date.save
      # redirect_to quote_path(@quote), notice: "Date was successfully created."
      respond_to do |f|
        f.html { redirect_to quote_path(@quote), notice: "Date was successfully created." }
        f.turbo_stream { flash.now[:notice] = "Date was successfully created" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @line_item_date
  end

  def update
    authorize @line_item_date

    if @line_item_date.update(line_item_date_params)
      respond_to do |f|
        f.html { redirect_to quote_path(@quote), notice: "Date was successfully updated." }
        f.turbo_stream { flash.now[:notice] = "Date was successfully updated" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @line_item_date

    @line_item_date.destroy

    respond_to do |f|
      f.html {
        redirect_to quote_path(@quote), notice: "Date was successfully destroyed."
      }
      f.turbo_stream {
        flash.now[:notice] = "Date was successfully deleted."
      }
    end
  end

  private

  def line_item_date_params
    params.require(:line_item_date).permit(:date)
  end

  def set_quote
    @quote = current_company.quotes.find(params[:quote_id])
  end

  def set_line_item_date
    @line_item_date = @quote.line_item_dates.find(params[:id])
  end
end
