require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncSites, sidekiq: true do
  describe 'course study modes' do
    context 'when the course has no course options' do
      let(:course) { create(:course) }

      it 'returns both study modes if the course supports both study modes' do
        course.full_time_or_part_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end

      it 'returns one study mode if the course only supports one' do
        course.full_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time]
      end
    end

    context 'when the course has existing course options with uniform study modes' do
      let(:course) do
        create(:course, :part_time) do |course|
          course.course_options = [
              create(:course_option, :part_time, course: course),
              create(:course_option, :part_time, course: course),
              create(:course_option, :part_time, course: course),
          ]
        end
      end

      it 'returns the existing study mode' do
        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[part_time]
      end

      it 'returns both study modes if the course changes to support both study modes' do
        course.full_time_or_part_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end

      it 'returns both study modes if the course changes from one to the other' do
        course.full_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end
    end

    context 'when the course has existing course options with a mix of study modes' do
      let(:course) do
        create(:course, :with_both_study_modes) do |course|
          course.course_options = [
              create(:course_option, :part_time, course: course),
              create(:course_option, :part_time, course: course),
              create(:course_option, :full_time, course: course),
          ]
        end
      end

      it 'returns both study modes' do
        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end

      it 'returns both study modes even if the course changes to a specific one' do
        course.full_time!

        study_modes = described_class.new.send(:study_modes, course)
        expect(study_modes).to match_array %w[full_time part_time]
      end
    end
  end
end
