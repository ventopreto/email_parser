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
    return log_error_and_nil("Parser not found for this email format.") unless parser_class

    data = parse_email_with(parser_class)
    return log_error_and_nil("Failed to parse customer data from email.", parser_class.name) unless data

    customer = find_or_build_customer(data)
    update_customer(customer, data)

    customer.save!
    log_success(data, parser_class.name)
    customer

  rescue => e
    log_error("An error occurred: #{e.message}", parser_class&.name)
    nil
  end

  private

  def determine_parser
    case @mail.from&.first
    when "loja@fornecedorA.com"
      Parsers::SupplierA
    when "contato@parceiroB.com"
      Parsers::PartnerB
    end
  end

  def parse_email_with(parser_class)
    parser_class.new(@mail.to_s).parse
  end

  def find_or_build_customer(data)
    if data[:email].present?
      Customer.find_or_initialize_by(email: data[:email])
    elsif data[:phone].present?
      Customer.find_or_initialize_by(phone: data[:phone])
    else
      Customer.new
    end
  end

  def update_customer(customer, data)
    customer.name  = data[:name]  if data[:name].present?
    customer.email = data[:email] if data[:email].present?
    customer.phone = data[:phone] if data[:phone].present?
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

  def log_error_and_nil(message, parser_name = nil)
    log_error(message, parser_name)
    nil
  end
end
