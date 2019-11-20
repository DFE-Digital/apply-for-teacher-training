require 'rails_helper'

RSpec.describe EmailAddressValidator do
  before do
    stub_const('Validatable', Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :email_address
      validates :email_address, email_address: true
    end
  end

  context 'when an email address is in an invalid format' do
    let(:model) { Validatable.new }

    before do
      model.email_address = 'foo'
      model.validate(:no_context)
    end

    it 'returns invalid' do
      expect(model).not_to be_valid
    end

    it 'returns the correct error message' do
      expect(model.errors[:email_address]).to include(t('activerecord.errors.models.candidate.attributes.email_address.invalid'))
    end
  end
end
