class AddParserNameToProcessingLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :processing_logs, :parser_name, :string
  end
end
