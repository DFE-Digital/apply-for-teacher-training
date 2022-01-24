require 'rails_helper'

RSpec.describe Note do
  describe 'validations' do
    it 'validates presence of and length of :message' do
      expect(described_class.new).to validate_presence_of(:message)
        .with_message('Enter a note')

      expect(described_class.new).to validate_length_of(:message)
        .is_at_most(500)
        .with_message('The note must be 500 characters or fewer')
    end
  end

  it 'changes updated_at on the associated ApplicationChoice' do
    choice = create(:application_choice)

    expect {
      create(:note, application_choice: choice)
    }.to(change { choice.updated_at })
  end
end
