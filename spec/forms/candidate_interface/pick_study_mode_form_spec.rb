require 'rails_helper'

RSpec.describe CandidateInterface::PickStudyModeForm, type: :model do
  let(:course) { build(:course) }

  describe '#available_sites' do
    before do
      create_list(:course_option, 2, :no_vacancies, course: course, study_mode: :part_time)
    end

    context 'when there are multiple course sites with no available vacancies for a study mode' do
      it 'returns no results' do
        form = described_class.new(course_id: course.id, study_mode: :part_time)

        expect(form.available_sites).to be_empty
      end
    end

    context 'when there multiple course sites with available vacancies for a study mode' do
      let!(:course_options) { create_list(:course_option, 2, :part_time, course: course) }

      before do
        create_list(:course_option, 2, :full_time, course: course)
      end

      it 'returns all available sites' do
        form = described_class.new(course_id: course.id, study_mode: :part_time)

        expect(form.available_sites).to match_array(course_options)
      end
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
