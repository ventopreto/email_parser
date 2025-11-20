class ProcessEmailJob < ApplicationJob
  queue_as :default

  def perform(email_content)
    EmailProcessorService.process(email_content)
  rescue => e
    ProcessingLog.create!(
      status: "error",
      error_message: "An error occurred in ProcessEmailJob: #{e.message}"
    )
  end
end
