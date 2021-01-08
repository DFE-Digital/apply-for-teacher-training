require 'rails_helper'

RSpec.describe Interview, type: :model do
  subject(:interview) { Interview.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:application_choice) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:date_and_time) }
  end

  describe '#offered_course' do
    it 'calls the application choice offered_course' do
      allow(interview.application_choice).to receive(:offered_course)

      interview.offered_course
      expect(interview.application_choice).to have_received(:offered_course)
    end
  end
end
