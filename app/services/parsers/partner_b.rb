module Parsers
  class PartnerB < Base
    def parse
      name = extract_name
      email = extract_email
      phone = extract_phone
      product_code = extract_product_code

      return nil unless name

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
      extract_field(body, [
        /Nome do cliente[: ]+(.*)/i,
        /Nome completo[: ]+(.*)/i,
        /Cliente[: ]+(.*)/i,
        /Nome[: ]+(.*)/i
      ])
    end

    def extract_email
      extract_field(body, [
        /E-mail de contato[: ]+(.*)/i,
        /Email de contato[: ]+(.*)/i,
        /E-mail[: ]+(.*)/i,
        /Email[: ]+(.*)/i
      ])
    end

    def extract_phone
      extract_field(body, [
        /Telefone[: ]+([\+\d\(\)\s-]+)/i,
        /Fone[: ]+([\+\d\(\)\s-]+)/i
      ])
    end

    def extract_product_code
      code =
        extract_field(subject, [
          /(PROD-[A-Z0-9]+)/i,
          /Pedido de informações[: ]+(PROD-[A-Z0-9]+)/i,
          /Solicitação recebida[: ]+(PROD-[A-Z0-9]+)/i
        ])

      return clean(code) if code.present?

      code = extract_field(body, [
        /produto de código[: ]+([A-Z0-9-]+)/i
      ])
      return clean(code) if code.present?

      code = extract_field(body, [
        /Código do produto[: ]+([A-Z0-9-]+)/i
      ])
      return clean(code) if code.present?

      code = extract_field(body, [
        /Produto[: ]+([A-Z0-9-]+)/i
      ])
      return clean(code) if code.present?

      code = extract_field(body, [
        /Produto de interesse[: ]+([A-Z0-9-]+)/i
      ])
      return clean(code) if code.present?

      nil
    end

    def clean(code)
      code&.strip&.gsub(/[^\w\-]+$/, "")
    end
  end
end
