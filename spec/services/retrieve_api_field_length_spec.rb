require 'rails_helper'

RSpec.describe RetrieveAPIFieldLength do
  it 'retrieves the max length of the provided field, as specified in the APIDocs' do
    expect(described_class.new('WorkExperiences.properties.work_history_break_explanation').call).to eq(10240)
  end
end
