require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::VolunteeringRoleForm, :with_audited, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_presence_of(:working_with_children) }
    it { is_expected.to validate_presence_of(:currently_working) }

    it { is_expected.to validate_length_of(:role).is_at_most(60) }
    it { is_expected.to validate_length_of(:organisation).is_at_most(60) }
    it { is_expected.to validate_presence_of(:audit_comment) }
  end

  describe '#update' do
    let(:volunteering_role) { create(:application_volunteering_experience, experienceable: application_form, role: 'Teacher', working_with_children: false) }
    let(:application_form) { create(:application_form) }

    let(:form_data) do
      {
        id: volunteering_role.id,
        role: 'School Experience Intern',
        organisation: Faker::Educator.secondary_school,
        details: Faker::Lorem.paragraph_by_chars(number: 300),
        working_with_children: 'true',
        start_date_month: 5,
        start_date_year: 2018,
        end_date_month: 5,
        end_date_year: 2019,
        currently_working: 'false',
        start_date_unknown: 'false',
        end_date_unknown: 'false',
        audit_comment: 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      }
    end

    it 'returns false if not valid' do
      expect(described_class.new.update(ApplicationWorkExperience.new)).to be(false)
    end

    it 'updates an existing role if valid' do
      role_form = described_class.new(form_data)

      expect(volunteering_role).to have_attributes(role: 'Teacher')
      expect(volunteering_role).to have_attributes(working_with_children: false)
      expect(volunteering_role.audits.find_by(action: 'update')).to be_nil

      role_form.update(application_form)

      expect(volunteering_role.reload).to have_attributes(role: 'School Experience Intern')
      expect(volunteering_role.reload).to have_attributes(working_with_children: true)
      expect(volunteering_role.audits.find_by(action: 'update').comment).to eq 'https://becomingateacher.zendesk.com/agent/tickets/12345'
    end
  end
end
