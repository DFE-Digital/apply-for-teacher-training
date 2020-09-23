require 'rails_helper'

RSpec.describe FindSync::CourseVacancyStatus do
  describe '#derive' do
    context 'when study_mode is part_time' do
      let(:study_mode) { 'part_time' }

      [
        { description: 'no_vacancies', vacancy_status: :no_vacancies },
        { description: 'both_full_time_and_part_time_vacancies', vacancy_status: :vacancies },
        { description: 'full_time_vacancies', vacancy_status: :no_vacancies },
        { description: 'part_time_vacancies', vacancy_status: :vacancies },
      ].each do |pair|
        it "returns #{pair[:vacancy_status]} when description is #{pair[:description]}" do
          derived_status = FindSync::CourseVacancyStatus.new(
            pair[:description],
            study_mode,
          ).derive

          expect(derived_status).to eq pair[:vacancy_status]
        end
      end

      it 'raises an error when description is an unexpected value' do
        expect {
          FindSync::CourseVacancyStatus.new('foo', study_mode).derive
        }.to raise_error(
          FindSync::CourseVacancyStatus::InvalidFindStatusDescriptionError,
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
          derived_status = FindSync::CourseVacancyStatus.new(
            pair[:description],
            study_mode,
          ).derive

          expect(derived_status).to eq pair[:vacancy_status]
        end
      end

      it 'raises an error when description is an unexpected value' do
        expect {
          FindSync::CourseVacancyStatus.new('foo', study_mode).derive
        }.to raise_error(
          FindSync::CourseVacancyStatus::InvalidFindStatusDescriptionError,
        )
      end
    end
  end
end
