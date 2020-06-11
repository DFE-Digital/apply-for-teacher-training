require 'rails_helper'

RSpec.describe CandidateInterface::PickChoiceToReplaceForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:id) }
  end
end
