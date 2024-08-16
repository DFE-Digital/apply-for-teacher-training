require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::JobForm, :with_audited, type: :model do
  let(:form_data) do
    {
      role: 'Senior Teacher',
      organisation: Faker::Educator.secondary_school,
      commitment: 'full_time',
      start_date_month: 5,
      start_date_year: 2019,
      start_date_unknown: 'false',
      end_date_month: 6,
      end_date_year: 2023,
      end_date_unknown: 'false',
      currently_working: 'false',
      relevant_skills: 'false',
      audit_comment: 'https://becomingateacher.zendesk.com/agent/tickets/12345',
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_presence_of(:commitment) }

    it { is_expected.to validate_length_of(:role).is_at_most(100) }
    it { is_expected.to validate_length_of(:organisation).is_at_most(100) }
    it { is_expected.to validate_presence_of(:audit_comment) }
  end

  describe '#update' do
    let(:job) { create(:application_work_experience, experienceable: application_form, role: 'Teacher') }
    let(:application_form) { create(:application_form) }

    it 'returns false if not valid' do
      expect(described_class.new.update(ApplicationWorkExperience.new)).to be(false)
    end

    it 'updates an existing job if valid' do
      job_form = described_class.new(form_data)

      expect(job).to have_attributes(role: 'Teacher')
      expect(job).to have_attributes(relevant_skills: true)
      expect(job).to have_attributes(details: 'I used skills relevant to teaching in this job.')
      expect(job.audits.find_by(action: 'update')).to be_nil

      job_form.update(job)

      expect(job).to have_attributes(role: 'Senior Teacher')
      expect(job).to have_attributes(relevant_skills: false)
      expect(job).to have_attributes(details: 'I did not use skills relevant to teaching in this job.')
      expect(job.audits.find_by(action: 'update').comment).to eq 'https://becomingateacher.zendesk.com/agent/tickets/12345'
    end
  end
end
