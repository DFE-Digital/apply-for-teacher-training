require 'rails_helper'

RSpec.describe CandidateInterface::PickStudyModeForm, type: :model do
  let!(:course) { create(:course) }

  describe '#available_sites' do
    it 'returns all sites available for the selected course and study mode' do
      pt_course_one = create(:course_option, course: course, study_mode: :part_time)
      pt_course_two = create(:course_option, course: course, study_mode: :part_time)
      create(:course_option, course: course, study_mode: :full_time)

      form = described_class.new(course_id: course.id, study_mode: :part_time)

      expect(form.available_sites).to eq(
        [
          pt_course_one,
          pt_course_two,
        ],
      )
    end
  end

  describe 'single_site_course?' do
    it 'returns true when there is only one available site' do
      create(:course_option, course: course, study_mode: :full_time)

      form = described_class.new(course_id: course.id, study_mode: :full_time)

      expect(form.single_site_course?).to eq true
    end

    it 'returns false when there is more than one available site' do
      create(:course_option, course: course, study_mode: :full_time)
      create(:course_option, course: course, study_mode: :full_time)

      form = described_class.new(course_id: course.id, study_mode: :full_time)

      expect(form.single_site_course?).to eq false
    end
  end

  describe 'first_site_id' do
    it 'returns the id of the first available site' do
      course_option = create(:course_option, course: course, study_mode: :full_time)

      form = described_class.new(course_id: course.id, study_mode: :full_time)

      expect(form.first_site_id).to eq course_option.id
    end

    context 'when there are no sites' do
      it 'returns nil' do
        form = described_class.new(course_id: course.id, study_mode: :full_time)

        expect(form.first_site_id).to eq nil
      end
    end
  end
end
