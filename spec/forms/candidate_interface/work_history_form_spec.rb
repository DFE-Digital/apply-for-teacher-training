require 'rails_helper'

RSpec.describe CandidateInterface::WorkHistoryForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:work_history) }
  end
end
