require 'rails_helper'

RSpec.describe PostcodeValidator do
  before do
    stub_const('Validatable', Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :postcode
      validates :postcode, postcode: true
    end
  end

  context 'with a valid UK postcode' do
    it 'does not add an error' do
      model = Validatable.new

      model.postcode = 'SE1 1TE'

      expect(model).to be_valid
      expect(model.errors[:postcode]).to be_blank
    end
  end

  context 'with a valid UK postcode' do
    it 'adds an error' do
      model = Validatable.new

      model.postcode = 'MUCH WOW'

      expect(model).not_to be_valid
      expect(model.errors[:postcode]).not_to be_blank
    end
  end
end
