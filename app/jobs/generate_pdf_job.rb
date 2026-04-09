require 'aws-sdk-s3'

class GeneratePdfJob < ApplicationJob
  queue_as :default

  def perform(company_id)
    company = Company.find(company_id)

    company.update!(pdf_status: "processing")

    begin
      pdf = CompanyQuotePdf.new(company).call
      file = StringIO.new(pdf.render)

      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      bucket = s3.bucket(ENV['AWS_BUCKET'])

      key = "companies/company_#{company.id}_quotes.pdf"
      obj = bucket.object(key)

      obj.put(
        body: file,
        content_type: "application/pdf",
      )

      company.update!(
        pdf_status: "completed",
        pdf_url: key
      )
    rescue => e
      Rails.logger.error("PDF FAILED: #{e.message}")

      company.update!(pdf_status: "failed")   # IMPORTANT
    end
  end
end
