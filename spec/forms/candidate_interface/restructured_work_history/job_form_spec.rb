require 'rails_helper'

RSpec.describe CandidateInterface::RestructuredWorkHistory::JobForm, type: :model do
  let(:data) do
    {
      role: ['Teacher', 'Teaching Assistant'].sample,
      organisation: Faker::Educator.secondary_school,
      commitment: %w[full_time part_time].sample,
      start_date: Time.zone.local(2018, 5, 1),
      start_date_unknown: false,
      end_date: Time.zone.local(2019, 5, 1),
      end_date_unknown: false,
      currently_working: false,
      relevant_skills: true,
    }
  end

  let(:form_data) do
    {
      role: data[:role],
      organisation: data[:organisation],
      commitment: data[:commitment],
      start_date_month: data[:start_date].month,
      start_date_year: data[:start_date].year,
      start_date_unknown: data[:start_date_unknown].to_s,
      end_date_month: data[:end_date].month,
      end_date_year: data[:end_date].year,
      end_date_unknown: data[:end_date_unknown].to_s,
      currently_working: data[:currently_working].to_s,
      relevant_skills: data[:relevant_skills].to_s,
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_presence_of(:commitment) }

    it { is_expected.to validate_length_of(:role).is_at_most(60) }
    it { is_expected.to validate_length_of(:organisation).is_at_most(60) }

    include_examples 'validation for a start date', 'restructured_work_history/job_form', verify_presence: true

    context "'currently working' is 'false'" do
      it 'is invalid if left completely blank' do
        form = described_class.new(end_date_month: '', end_date_year: '', currently_working: 'false')

        form.validate

        expect(form.errors[:end_date]).to contain_exactly('Enter an end date')
      end

      it 'is invalid if month left blank' do
        form = described_class.new(end_date_month: '', end_date_year: '2019', currently_working: 'false')

        form.validate

        expect(form.errors[:end_date]).to contain_exactly('The end date must include a month')
      end

      it 'is invalid if year left blank' do
        form = described_class.new(end_date_month: '5', end_date_year: '', currently_working: 'false')

        form.validate

        expect(form.errors[:end_date]).to contain_exactly('The end date must include a year')
      end

      it 'is invalid if not well-formed' do
        form = described_class.new(end_date_month: '99', end_date_year: '2019', currently_working: 'false')

        form.validate

        expect(form.errors[:end_date]).to contain_exactly('Enter an end date in the correct format, for example 5 2019')
      end

      it 'is invalid if year is beyond the current year' do
        Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
          form = described_class.new(end_date_month: '1', end_date_year: '2029', currently_working: 'false')

          form.validate

          expect(form.errors[:end_date]).to contain_exactly('Enter an end date that is not in the future')
        end
      end

      it 'is invalid if year is the current year but month is after the current month' do
        Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
          form = described_class.new(end_date_month: '11', end_date_year: '2019', currently_working: 'false')

          form.validate

          expect(form.errors[:end_date]).to contain_exactly('Enter an end date that is not in the future')
        end
      end

      it 'is valid if year and month are before the current year and month' do
        Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
          form = described_class.new(end_date_month: '9', end_date_year: '2019', currently_working: 'false')

          form.validate

          expect(form.errors.full_messages_for(:end_date)).to be_empty
        end
      end
    end

    context "'currently_working' is true" do
      it "does not validate 'end_date'" do
        form = described_class.new(currently_working: 'true')

        form.validate

        expect(form.errors.full_messages_for(:end_date)).to be_empty
      end
    end

    it 'does not accept negative integers in the year field' do
      form_data[:start_date_year] = -1999
      form_data[:end_date_year]   = -1999
      job = CandidateInterface::RestructuredWorkHistory::JobForm.new(form_data)

      expect(job).not_to be_valid
      errors = job.errors.messages
      expect(errors[:start_date].pop).to eq 'Enter a start date in the correct format, for example 5 2019'
      expect(errors[:end_date].pop).to eq 'Enter an end date in the correct format, for example 5 2019'
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      job = CandidateInterface::RestructuredWorkHistory::JobForm.new

      expect(job.save(ApplicationForm.new)).to eq(false)
    end

    it 'creates a new job if valid' do
      application_form = FactoryBot.create(:application_form)
      job = CandidateInterface::RestructuredWorkHistory::JobForm.new(form_data)

      saved_job = job.save(application_form)
      expect(saved_job).to have_attributes(data)
      expect(saved_job.details).to eq 'I used skills relevant to teaching in this job.'
    end
  end

  describe '#update' do
    it 'returns false if not valid' do
      job = CandidateInterface::RestructuredWorkHistory::JobForm.new

      expect(job.update(ApplicationWorkExperience.new)).to eq(false)
    end

    it 'updates an existing job if valid' do
      application_form = FactoryBot.create(:application_form)
      job = CandidateInterface::RestructuredWorkHistory::JobForm.new(form_data)
      saved_job = job.save(application_form)

      job.role = 'Something else'
      job.relevant_skills = 'false'

      job.update(saved_job)

      expect(saved_job.reload).to have_attributes(role: 'Something else')
      expect(saved_job.reload).to have_attributes(relevant_skills: false)
      expect(saved_job.reload).to have_attributes(details: 'I did not use skills relevant to teaching in this job.')
    end
  end

  describe '.build_form' do
    it 'creates an object based on the provided experience' do
      form_data[:start_date_unknown] = data[:start_date_unknown]
      form_data[:end_date_unknown] = data[:end_date_unknown]
      application_work_experience = ApplicationWorkExperience.new(data)
      job_form = CandidateInterface::RestructuredWorkHistory::JobForm.build_form(application_work_experience)

      expect(job_form).to have_attributes(form_data)
    end

    it 'returns an empty string if end date is nil' do
      data[:end_date] = nil
      application_work_experience = ApplicationWorkExperience.new(data)
      job_form = CandidateInterface::RestructuredWorkHistory::JobForm.build_form(
        application_work_experience,
      )

      expect(job_form).to have_attributes(
        end_date_day: '',
        end_date_month: '',
        end_date_year: '',
      )
    end
  end
end
