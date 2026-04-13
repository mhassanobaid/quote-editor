class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]

  def index
    @quotes = policy_scope(Quote).ordered
  end

  def show
    authorize @quote

    @line_item_dates = @quote.line_item_dates.includes(:line_items).ordered
  end

  def new
    @quote = Quote.new
    authorize @quote
  end

  def create
    @quote = current_company.quotes.build(quote_params)
    authorize @quote

    if @quote.save
      respond_to do |f|
        f.html { redirect_to quotes_path, notice: "Quote was successfully created." }
        f.turbo_stream { flash.now[:notice] = "Quote was successfully created." }
      end
    else
      # fix to error of form responses be directed to anothre location
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @quote
  end

  def update
    authorize @quote

    if @quote.update(quote_params)
      respond_to do |format|
        format.html { redirect_to quotes_path, notice: "Quote was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Quote was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @quote

    @quote.destroy
    respond_to do |format|
      format.html { redirect_to quotes_path, notice: "Quote was successfully destroyed." }
      format.turbo_stream { flash.now[:notice] = "Quote was successfully destroyed." }
    end
  end

  def generate_pdf
    company = current_company

    company.update!(pdf_status: "pending")

    GeneratePdfJob.perform_later(company.id)

    render json: { status: "started" }
  end

  def pdf_status
    company = current_company

    if company.pdf_status == "completed" && company.pdf_url.present?
      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      obj = s3.bucket(ENV['AWS_BUCKET']).object(company.pdf_url)

      # Generate presigned URL (valid for 5 minutes)
      url = obj.presigned_url(:get, expires_in: 300)

      render json: {
        status: "completed",
        url: url
      }
    else
      render json: {
        status: company.pdf_status
      }
    end
  end

  private

  def set_quote
    @quote = current_company.quotes.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name)
  end
end
