require 'rails_helper'

RSpec.describe CandidateInterface::WorkExperienceForm, type: :model do
  let(:data) do
    {
      role: ['Teacher', 'Teaching Assistant'].sample,
      organisation: Faker::Educator.secondary_school,
      details: Faker::Lorem.paragraph_by_chars(number: 300),
      commitment: %w[full_time part_time].sample,
      working_with_children: [true, true, true, false].sample,
      start_date: Time.zone.local(2018, 5, 1),
      end_date: Time.zone.local(2019, 5, 1),
      working_pattern: Faker::Lorem.paragraph_by_chars(number: 20),
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
      working_pattern: data[:working_pattern],
    }
  end

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

    context 'start_date validations' do
      let(:model) do
        described_class.new(start_date_day: start_date_day,
                            start_date_month: start_date_month,
                            start_date_year: start_date_year)
      end

      include_examples 'month and year date validations', :start_date, verify_presence: true, future: true, before: :end_date
    end

    context 'end_date validations' do
      let(:model) do
        described_class.new(end_date_day: end_date_day,
                            end_date_month: end_date_month,
                            end_date_year: end_date_year)
      end

      include_examples 'month and year date validations', :end_date, future: true
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      work_experience = described_class.new

      expect(work_experience.save(ApplicationForm.new)).to be(false)
    end

    it 'creates a new work experience if valid' do
      application_form = create(:application_form)
      work_experience = described_class.new(form_data)

      saved_work_experience = work_experience.save(application_form)
      expect(saved_work_experience).to have_attributes(data)
    end
  end

  describe '#update' do
    it 'returns false if not valid' do
      work_experience = described_class.new

      expect(work_experience.update(ApplicationWorkExperience.new)).to be(false)
    end

    it 'updates an existing work experience if valid' do
      application_form = create(:application_form)
      work_experience = described_class.new(form_data)

      saved_work_experience = work_experience.save(application_form)

      work_experience.role = 'Something else'
      work_experience.working_pattern = 'New working pattern'
      work_experience.update(saved_work_experience)
      expect(saved_work_experience.reload).to have_attributes(role: 'Something else')
      expect(saved_work_experience.reload).to have_attributes(working_pattern: 'New working pattern')
    end
  end

  describe '.build_from_experience' do
    it 'creates an object based on the provided experience' do
      application_work_experience = ApplicationWorkExperience.new(data)
      work_experience_form = described_class.build_from_experience(
        application_work_experience,
      )

      expect(work_experience_form).to have_attributes(form_data)
    end

    it 'returns an empty string if end date is nil' do
      data[:end_date] = nil
      application_work_experience = ApplicationWorkExperience.new(data)
      work_experience_form = described_class.build_from_experience(
        application_work_experience,
      )

      expect(work_experience_form).to have_attributes(
        end_date_day: '',
        end_date_month: '',
        end_date_year: '',
      )
    end
  end
end
