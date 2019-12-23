require 'rails_helper'

RSpec.describe EmailAddressValidator do
  before do
    stub_const('Validatable', Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :email_address
      validates :email_address, email_address: true
    end
  end

  context 'when an email address has a valid format' do
    let(:model) { Validatable.new }
    let(:valid_emails) do
      [
        'email@domain.com',
        'email@domain.COM',
        'firstname.lastname@domain.com',
        'firstname.o\'lastname@domain.com',
        'email@subdomain.domain.com',
        'firstname+lastname@domain.com',
        '1234567890@domain.com',
        'email@domain-one.com',
        '_______@domain.com',
        'email@domain.name',
        'email@domain.superlongtld',
        'email@domain.co.jp',
        'firstname-lastname@domain.com',
        'info@german-financial-services.vermögensberatung',
        'info@german-financial-services.reallylongarbitrarytldthatiswaytoohugejustincase',
        'japanese-info@例え.テスト',
    ]
    end

    it 'returns valid' do
      valid_emails.each do |email|
        model.email_address = email
        model.validate(:no_context)
        expect(model).to be_valid
      end
    end
  end

  context 'when an email address is in an invalid format' do
    let(:model) { Validatable.new }
    let(:invalid_emails) do
      [
      'email@[123.123.123.123]',
      'plainaddress',
      '@no-local-part.com',
      'Outlook Contact <outlook-contact@domain.com>',
      'no-at.domain.com',
      'no-tld@domain',
      ';beginning-semicolon@domain.co.uk',
      'middle-semicolon@domain.co;uk',
      'trailing-semicolon@domain.com;',
      '"email+leading-quotes@domain.com',
      'email+middle"-quotes@domain.com',
      '"quoted-local-part"@domain.com',
      '"quoted@domain.com"',
      'lots-of-dots@domain..gov..uk',
      'multiple@domains@domain.com',
      'spaces in local@domain.com',
      'spaces-in-domain@dom ain.com',
      'underscores-in-domain@dom_ain.com',
      'pipe-in-domain@example.com|gov.uk',
      'comma,in-local@gov.uk',
      'comma-in-domain@domain,gov.uk',
      'pound-sign-in-local£@domain.com',
      'local-with-’-apostrophe@domain.com',
      'local-with-”-quotes@domain.com',
      'domain-starts-with-a-dot@.domain.com',
      'brackets(in)local@domain.com',
    ]
    end

    it 'returns invalid' do
      invalid_emails.each do |email|
        model.email_address = email
        model.validate(:no_context)
        expect(model).not_to be_valid
      end
    end

    it 'returns the correct error message' do
      model.email_address = 'foo'
      model.validate(:no_context)
      expect(model.errors[:email_address]).to include(t('activerecord.errors.models.candidate.attributes.email_address.invalid'))
    end
  end
end
