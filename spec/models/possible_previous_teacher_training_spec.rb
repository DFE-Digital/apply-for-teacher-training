require 'rails_helper'

RSpec.describe PossiblePreviousTeacherTraining do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to belong_to(:provider).optional }
  end

  describe 'validations' do
    subject(:possible_previous_teacher_training) do
      build(:possible_previous_teacher_training,
            provider_name: 'London Provider',
            started_on: Date.current,
            ended_on: Date.current + 1.year)
    end

    it { is_expected.to validate_presence_of(:provider_name) }
    it { is_expected.to validate_presence_of(:started_on) }
    it { is_expected.to validate_presence_of(:ended_on) }
    it { is_expected.to validate_comparison_of(:ended_on).is_greater_than_or_equal_to(:started_on) }
  end
end
