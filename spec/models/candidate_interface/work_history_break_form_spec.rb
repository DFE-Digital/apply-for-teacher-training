require 'rails_helper'

RSpec.describe CandidateInterface::WorkHistoryBreakForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:reason) }

    okay_text = Faker::Lorem.sentence(word_count: 400)
    long_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(okay_text).for(:reason) }
    it { is_expected.not_to allow_value(long_text).for(:reason) }

    include_examples 'validation for a start and end date', 'work_history_break_form'
  end
end
