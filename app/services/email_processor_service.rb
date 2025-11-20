# frozen_string_literal: true

class EmailProcessorService
  def self.process(email_content)
    new(email_content).process
  end

  def initialize(email_content)
    @mail = Mail.read_from_string(email_content)
  end

  def process
    parser_class = determine_parser
    unless parser_class
      log_error("Parser not found for this email format.")
      return
    end

    parser = parser_class.new(@mail.to_s)
    data = parser.parse

    if data
      customer = nil
      if data[:email].present?
        customer = Customer.find_or_initialize_by(email: data[:email])
      elsif data[:phone].present?
        customer = Customer.find_or_initialize_by(phone: data[:phone])
      else
        customer = Customer.new
      end

      if customer
        customer.name = data[:name] if data[:name].present?
        customer.email = data[:email] if data[:email].present?
        customer.phone = data[:phone] if data[:phone].present?
        customer.save!

        log_success(data, parser_class.name)
        customer
      else
        log_error("Failed to process customer data even after parsing. No customer object could be initialized.", parser_class&.name)
        nil
      end
    else
      log_error("Failed to parse customer data from email.", parser_class&.name)
      nil
    end
  rescue => e
    log_error("An error occurred: #{e.message}", parser_class&.name)
    nil
  end

  private

  def determine_parser
    from_address = @mail.from&.first
    case from_address
    when "loja@fornecedorA.com"
      Parsers::SupplierA
    when "contato@parceiroB.com"
      Parsers::PartnerB
    end
  end

  def log_success(data, parser_name = nil)
    ProcessingLog.create!(
      status: "success",
      extracted_data_json: data,
      parser_name: parser_name
    )
  end

  def log_error(message, parser_name = nil)
    ProcessingLog.create!(
      status: "error",
      error_message: message,
      parser_name: parser_name
    )
  end
end
