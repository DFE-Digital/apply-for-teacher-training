require 'rails_helper'

RSpec.describe CandidateInterface::PersonalDetailsForm, type: :model do
  describe '#name' do
    it 'concatenates the first name and last name ' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(first_name: 'Bruce', last_name: 'Wayne')

      expect(personal_details.name).to eq('Bruce Wayne')
    end
  end

  describe '#english_main_language_options' do
    it 'returns an array of OpenStructs with id and name' do
      personal_details = CandidateInterface::PersonalDetailsForm.new

      expect(personal_details.english_main_language_options).to all(be_an(OpenStruct))
      expect(personal_details.english_main_language_options[0]).to have_attributes(id: 'yes', name: 'Yes')
      expect(personal_details.english_main_language_options[1]).to have_attributes(id: 'no', name: 'No')
    end
  end
end
