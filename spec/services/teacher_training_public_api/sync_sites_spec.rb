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

  describe 'course vacancy statuses' do
    context 'when study_mode is part_time' do
      let(:study_mode) { 'part_time' }

      [
        { description: 'no_vacancies', vacancy_status: :no_vacancies },
        { description: 'both_full_time_and_part_time_vacancies', vacancy_status: :vacancies },
        { description: 'full_time_vacancies', vacancy_status: :no_vacancies },
        { description: 'part_time_vacancies', vacancy_status: :vacancies },
      ].each do |pair|
        it "returns #{pair[:vacancy_status]} when description is #{pair[:description]}" do
          derived_status = described_class.new.send(:vacancy_status,
                                                    pair[:description],
                                                    study_mode)

          expect(derived_status).to eq pair[:vacancy_status]
        end
      end

      it 'raises an error when description is an unexpected value' do
        expect {
          described_class.new.send(:vacancy_status, 'foo', study_mode)
        }.to raise_error(
          TeacherTrainingPublicAPI::SyncSites::InvalidVacancyStatusDescriptionError,
        )
      end
    end

    context 'when study_mode is full_time' do
      let(:study_mode) { 'full_time' }

      [
        { description: 'no_vacancies', vacancy_status: :no_vacancies },
        { description: 'both_full_time_and_part_time_vacancies', vacancy_status: :vacancies },
        { description: 'full_time_vacancies', vacancy_status: :vacancies },
        { description: 'part_time_vacancies', vacancy_status: :no_vacancies },
      ].each do |pair|
        it "returns #{pair[:vacancy_status]} when description is #{pair[:description]}" do
          derived_status = described_class.new.send(:vacancy_status,
                                                    pair[:description],
                                                    study_mode)

          expect(derived_status).to eq pair[:vacancy_status]
        end
      end

      it 'raises an error when description is an unexpected value' do
        expect {
          described_class.new.send(:vacancy_status, 'foo', study_mode)
        }.to raise_error(
          TeacherTrainingPublicAPI::SyncSites::InvalidVacancyStatusDescriptionError,
        )
      end
    end
  end

  describe '#handle_course_options_with_reinstated_sites' do
    context 'when site was previously withdrawn' do
      let(:course) do
        create(:course, :part_time) do |course|
          course.course_options = [
            create(:course_option, :part_time, course: course, site_still_valid: true),
            create(:course_option, :part_time, course: course, site_still_valid: true),
            create(:course_option, :part_time, course: course, site_still_valid: false),
          ]
        end
      end

      it 'sets `site_still_valid` to false on any course options with missing sites' do
        described_class.new.tap do |sync_sites|
          sync_sites.instance_variable_set(:@course, course)
        end.send(
          :handle_course_options_with_reinstated_sites,
          course.course_options.map { |course_option| OpenStruct.new(code: course_option.site.code) },
        )
        course_options = course.course_options.reload
        expect(course_options[0].site_still_valid).to be(true)
        expect(course_options[1].site_still_valid).to be(true)
        expect(course_options[2].site_still_valid).to be(true)
      end
    end
  end
end
