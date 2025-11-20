# frozen_string_literal: true

module Parsers
  class PartnerB < Base
    def parse
      name = extract_name
      email = extract_email
      phone = extract_phone
      product_code = extract_product_code

      return nil unless name && email

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
      extract_field(body, [ /Nome: (.*)/, /Cliente: (.*)/, /Nome completo: (.*)/ ])
    end

    def extract_email
      extract_field(body, [ /E-mail: (.*)/, /Email: (.*)/, /E-mail de contato: (.*)/ ])
    end

    def extract_phone
      extract_field(body, [ /Telefone: (.*)/ ])
    end

    def extract_product_code
      product_code = extract_field(subject, [ /(PROD-\d+)/, /Solicitação recebida - (.*)/, /Pedido de informações - (.*)/ ])
      product_code ||= extract_field(body, [ /Código do produto: (.*)/, /Produto: (.*)/, /produto de código (\w+)/ ])
      product_code
    end
  end
end
