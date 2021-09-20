require 'rails_helper'

RSpec.describe DataMigrations::BackfillCoursesForNextCycle do
  describe '#change' do
    it 'opens all courses in new cycle' do
      course = create(:course, recruitment_cycle_year: RecruitmentCycle.next_year)
      described_class.new.change
      expect(course.reload).to be_open_on_apply
    end

    it 'doesnt open courses on apply which are in the current cycle' do
      current_cycle_course = create(:course, recruitment_cycle_year: RecruitmentCycle.current_year)
      described_class.new.change
      expect(current_cycle_course.reload).not_to be_open_on_apply
    end
  end
end
