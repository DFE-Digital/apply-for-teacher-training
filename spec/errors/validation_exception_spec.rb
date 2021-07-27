require 'rails_helper'

RSpec.describe ValidationException do
  let(:test_validation_exception) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :name, :surname

      validates :name, :surname, presence: true

      def execute
        raise ValidationException, errors.full_messages unless valid?
      end
    end
  end

  let(:name) { nil }
  let(:surname) { nil }

  before do
    stub_const('TestValidationException', test_validation_exception)
  end

  it 'contains the correct error messages' do
    model = TestValidationException.new(name: name, surname: surname)

    expect { model.execute }.to raise_error(described_class, 'Name can\'t be blank, Surname can\'t be blank')
  end

  it 'can return the error messages in json format' do
    TestValidationException.new(name: name, surname: surname).execute
  rescue described_class => e
    expect(e.as_json).to eq(errors: [{ error: 'ValidationError', message: 'Name can\'t be blank' },
                                     { error: 'ValidationError', message: 'Surname can\'t be blank' }])
  end
end
