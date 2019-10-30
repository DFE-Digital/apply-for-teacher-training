require 'rails_helper'

RSpec.describe CandidateInterface::WorkExperienceForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_presence_of(:details) }
    it { is_expected.to validate_presence_of(:working_with_children) }
    it { is_expected.to validate_presence_of(:commitment) }

    it { is_expected.to validate_length_of(:role).is_at_most(60) }
    it { is_expected.to validate_length_of(:organisation).is_at_most(60) }


    okay_text = Faker::Lorem.sentence(word_count: 150)
    long_text = Faker::Lorem.sentence(word_count: 151)

    it { is_expected.to allow_value(okay_text).for(:details) }
    it { is_expected.not_to allow_value(long_text).for(:details) }

    describe 'start date' do
      it 'is invalid if not well-formed' do
        work_experience = CandidateInterface::WorkExperienceForm.new(
          start_date_month: '99', start_date_year: '99',
        )

        work_experience.validate

        expect(work_experience.errors.full_messages_for(:start_date)).to eq(
          ["Start date #{t('activemodel.errors.models.candidate_interface/work_experience_form.attributes.start_date.invalid')}"],
        )
      end

      it 'is invalid if the date is after the end date' do
        work_experience = CandidateInterface::WorkExperienceForm.new(
          start_date_month: '5', start_date_year: '2018',
          end_date_month: '5', end_date_year: '2017'
        )

        work_experience.validate

        expect(work_experience.errors.full_messages_for(:start_date)).to eq(
          ["Start date #{t('activemodel.errors.models.candidate_interface/work_experience_form.attributes.start_date.before')}"],
        )
      end
    end
  end

  describe '#save' do
    let(:data) do
      {
        role: ['Teacher', 'Teaching Assistant'].sample,
        organisation: Faker::Educator.secondary_school,
        details: Faker::Lorem.paragraph_by_chars(number: 300),
        commitment: %w[full_time part_time].sample,
        working_with_children: [true, true, true, false].sample,
        start_date: Date.new(2018, 5),
        end_date: Date.new(2019, 5),
      }
    end

    let(:form_data) do
      {
        role: data[:role],
        organisation: data[:organisation],
        details: data[:details],
        commitment: data[:commitment],
        working_with_children: data[:working_with_children].to_s,
        start_date_month: data[:start_date].month,
        start_date_year: data[:start_date].year,
        end_date_month: data[:end_date].month,
        end_date_year: data[:end_date].year,
      }
    end

    it 'returns false if not valid' do
      work_experience = CandidateInterface::WorkExperienceForm.new

      expect(work_experience.save(ApplicationForm.new)).to eq(false)
    end

    it 'creates a new work experience if valid' do
      application_form = FactoryBot.create(:application_form)
      work_experience = CandidateInterface::WorkExperienceForm.new(form_data)

      saved_work_experience = work_experience.save(application_form)
      expect(saved_work_experience).to have_attributes(data)
    end
  end
end
