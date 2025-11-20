# frozen_string_literal: true

module Parsers
  class SupplierA < Base
    def parse
      name = extract_name
      email = extract_email
      phone = extract_phone
      product_code = extract_product_code

      return nil unless name && (email || phone)

      {
        name: name,
        email: email,
        phone: phone,
        product_code: product_code
      }
    end

    private

    def body
      @body ||= @mail.body.decoded
    end

    def subject
      @subject ||= @mail.subject
    end

    def extract_name
      extract_field(body, [ /Nome do cliente: (.*)/, /Nome: (.*)/ ])
    end

    def extract_email
      extract_field(body, [ /E-mail: (.*)/ ])
    end

    def extract_phone
      extract_field(body, [ /Telefone: (.*)/ ])
    end

    def extract_product_code
      product_code = extract_field(subject, [ /Produto (.*)/, /Interesse no produto (.*)/, /Solicitação de cotação - Produto (.*)/, /Pedido de orçamento - Produto (.*)/ ])
    end
  end
end
