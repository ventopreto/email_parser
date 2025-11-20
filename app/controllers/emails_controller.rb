class EmailsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    email_content = File.read(Rails.root.join("emails", "email1.eml"))

    ProcessEmailJob.perform_later(email_content)

    render json: { message: "Email processing has been enqueued." }, status: :accepted
  end
end
