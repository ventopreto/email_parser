# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parsers::SupplierA do
  describe '#parse' do
    context 'with email1.eml' do
      it 'extracts the customer data' do
        email_content = File.read(Rails.root.join('emails', 'email1.eml'))
        parser = described_class.new(email_content)
        result = parser.parse

        expect(result).to eq({
          name: 'João da Silva',
          email: 'joao.silva@example.com',
          phone: '(11) 91234-5678',
          product_code: 'ABC123'
        })
      end
    end

    context 'with email2.eml' do
      it 'extracts the customer data' do
        email_content = File.read(Rails.root.join('emails', 'email2.eml'))
        parser = described_class.new(email_content)
        result = parser.parse

        expect(result).to eq({
          name: 'Maria Oliveira',
          email: 'maria.oliveira@example.com',
          phone: '21 99876-5432',
          product_code: 'XYZ987'
        })
      end
    end

    context 'with email3.eml' do
      it 'extracts the customer data' do
        email_content = File.read(Rails.root.join('emails', 'email3.eml'))
        parser = described_class.new(email_content)
        result = parser.parse

        expect(result).to eq({
          name: 'Pedro Santos',
          email: 'pedro.santos@example.com',
          phone: nil,
          product_code: 'LMN456'
        })
      end
    end

    context 'with email7.eml (missing contact info)' do
      it 'returns nil' do
        email_content = File.read(Rails.root.join('emails', 'email7.eml'))
        parser = described_class.new(email_content)
        result = parser.parse

        expect(result).to be_nil
      end
    end
  end
end
