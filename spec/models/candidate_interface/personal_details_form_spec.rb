require 'rails_helper'

RSpec.describe CandidateInterface::PersonalDetailsForm, type: :model do
  describe '#name' do
    it 'concatenates the first name and last name ' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(first_name: 'Bruce', last_name: 'Wayne')

      expect(personal_details.name).to eq('Bruce Wayne')
    end
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:first_nationality) }
    it { should validate_presence_of(:english_main_language) }

    it { should validate_length_of(:first_name).is_at_most(100) }
    it { should validate_length_of(:last_name).is_at_most(100) }
  end
end
