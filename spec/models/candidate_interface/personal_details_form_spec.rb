require 'rails_helper'

RSpec.describe CandidateInterface::PersonalDetailsForm, type: :model do
  describe '#name' do
    it 'concatenates the first name and last name ' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(first_name: 'Bruce', last_name: 'Wayne')

      expect(personal_details.name).to eq('Bruce Wayne')
    end
  end
end
