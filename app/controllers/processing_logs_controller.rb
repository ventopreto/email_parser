class ProcessingLogsController < ApplicationController
  def index
    @processing_logs = ProcessingLog.all.order(created_at: :desc)
  end
end
