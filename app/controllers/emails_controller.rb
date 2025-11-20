class EmailsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ], if: -> { request.format.json? }

  def new
  end

  def create
    if params[:email_upload] && params[:email_upload][:file]
      email_content = params[:email_upload][:file].read
      ProcessEmailJob.perform_later(email_content)
      redirect_to processing_logs_path, notice: "Email processing has been enqueued."
    else
      email_content = File.read(Rails.root.join("emails", "email1.eml"))
      ProcessEmailJob.perform_later(email_content)
      render json: { message: "Email processing has been enqueued." }, status: :accepted
    end
  end
end
