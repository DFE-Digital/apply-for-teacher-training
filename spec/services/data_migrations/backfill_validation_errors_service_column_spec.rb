require 'rails_helper'

RSpec.describe DataMigrations::BackfillValidationErrorsServiceColumn do
  it 'assigns the apply service to all existing ValidationErrors' do
    create_list(:validation_error, 3, service: nil)

    described_class.new.change

    expect(ValidationError.all.pluck(:service).uniq).to eq(%w[apply])
  end
end
