# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parsers::PartnerB do
  describe '#parse' do
    let(:valid_body) do
      <<~EMAIL
        Prezados,

        Estou interessado no produto de código XYZ987.

        Dados de contato:
        Nome: Maria Oliveira
        E-mail: maria.oliveira@example.com
        Telefone: 21 99876-5432

        Aguardo retorno.
      EMAIL
    end

    let(:missing_name_body) do
      <<~EMAIL
        Dados de contato:
        E-mail: maria.oliveira@example.com
        Telefone: 21 99876-5432
      EMAIL
    end

    let(:missing_email_body) do
      <<~EMAIL
        Dados de contato:
        Nome: Maria Oliveira
        Telefone: 21 99876-5432
      EMAIL
    end

    let(:empty_body) { '' }

    context 'with a valid email body' do
      it 'extracts the customer data' do
        parser = described_class.new(valid_body)
        result = parser.parse
        expect(result).to eq({
          name: 'Maria Oliveira',
          email: 'maria.oliveira@example.com',
          phone: '21 99876-5432',
          product_code: 'XYZ987'
        })
      end
    end

    context 'when the name is missing' do
      it 'returns nil' do
        parser = described_class.new(missing_name_body)
        expect(parser.parse).to be_nil
      end
    end

    context 'when the email is missing' do
      it 'returns nil' do
        parser = described_class.new(missing_email_body)
        expect(parser.parse).to be_nil
      end
    end

    context 'with an empty email body' do
      it 'returns nil' do
        parser = described_class.new(empty_body)
        expect(parser.parse).to be_nil
      end
    end

    context 'with email4.eml' do
      it 'extracts the customer data' do
        email_content = File.read(Rails.root.join('emails', 'email4.eml'))
        parser = described_class.new(email_content)
        result = parser.parse

        expect(result).to eq({
          name: 'Ana Costa',
          email: 'ana.costa@example.com',
          phone: '+55 31 97777-1111',
          product_code: 'PROD-555'
        })
      end
    end

    context 'with email5.eml' do
      it 'extracts the customer data' do
        email_content = File.read(Rails.root.join('emails', 'email5.eml'))
        parser = described_class.new(email_content)
        result = parser.parse

        expect(result).to eq({
          name: 'Ricardo Almeida',
          email: 'ricardo.almeida@example.com',
          phone: '41 98888-2222',
          product_code: 'PROD-888'
        })
      end
    end

    context 'with email6.eml' do
      it 'returns nil because email is missing' do
        email_content = File.read(Rails.root.join('emails', 'email6.eml'))
        parser = described_class.new(email_content)
        result = parser.parse

        expect(result).to be_nil
      end
    end

    context 'with email8.eml (missing contact info)' do
      it 'returns nil' do
        email_content = File.read(Rails.root.join('emails', 'email8.eml'))
        parser = described_class.new(email_content)
        result = parser.parse

        expect(result).to be_nil
      end
    end
  end
end
