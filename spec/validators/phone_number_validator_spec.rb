require 'rails_helper'

RSpec.describe PhoneNumberValidator do
  before do
    stub_const('Validatable', Class.new).class_eval do
      include ActiveModel::Validations

      attr_accessor :phone_number
      validates :phone_number, phone_number: true
    end
  end

  context 'when nil phone number' do
    let(:model) { Validatable.new }

    before do
      model.phone_number = nil
      model.validate(:no_context)
    end

    it 'returns invalid' do
      expect(model).not_to be_valid
    end
  end

  context 'when empty phone number' do
    let(:model) { Validatable.new }

    before do
      model.phone_number = ''
      model.validate(:no_context)
    end

    it 'returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end
  end

  context 'when a phone number is in an invalid format' do
    it 'returns invalid' do
      model = Validatable.new
      invalid_phone_numbers = [
        '12 3 4 cat',
        '12dog34',
      ]

      invalid_phone_numbers.each do |phone_number|
        model.phone_number = phone_number

        model.validate(:no_context)

        expect(model).not_to be_valid
      end
    end
  end

  context 'when a valid phone number' do
    it 'correctly validates valid phone numbers' do
      model = Validatable.new
      valid_phone_numbers = [
        '+447123 123 123',
        '+407123 123 123',
        '+1 7123 123 123',
        '+447123123123',
        '07123123123',
        '01234 123 123 --()+ ',
        '01234 123 123 ext 123',
        '01234 123 123 x123',
        '(01234) 123123',
        '(12345) 123123',
        '(+44) (0)1234 123456',
        '+44 (0) 123 4567 123',
        '123 1234 1234 ext 123',
        '12345 123456 ext 123',
        '12345 123456 ext. 123',
        '12345 123456 ext123',
        '01234123456 ext 123',
        '123 1234 1234 x123',
        '12345 123456 x123',
        '12345123456 x123',
        '(1234) 123 1234',
        '1234 123 1234 x123',
        '1234 123 1234 ext 1234',
        '1234 123 1234  ext 123',
        '+44(0)123 12 12345',
      ]

      valid_phone_numbers.each do |number|
        model.phone_number = number

        expect(model).to be_valid
      end
    end
  end

  context 'when phone number is over 15 numbers' do
    it 'returns an error' do
      model = Validatable.new
      model.phone_number = '123456791123456789'
      model.validate

      expect(model).not_to be_valid
    end
  end

  context 'when phone number is 7 numbers or less' do
    it 'returns an error' do
      model = Validatable.new
      model.phone_number = '1234567'
      model.validate

      expect(model).not_to be_valid
    end
  end
end
