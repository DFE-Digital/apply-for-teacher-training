require 'rails_helper'

RSpec.describe ApplicationWorkExperience, type: :model do
  describe 'auditing', with_audited: true do
    it 'creates audit entries' do
      application_form = create :application_form
      application_work_experience = create :application_work_experience, application_form: application_form
      expect(application_work_experience.audits.count).to be 1
      expect {
        application_work_experience.update!(role: 'Rocket Surgeon')
      }.to change { application_work_experience.audits.count }.by(1)
    end

    it 'creates an associated object in each audit record' do
      application_form = create :application_form
      application_work_experience = create :application_work_experience, application_form: application_form
      expect(application_work_experience.audits.last.associated).to eq application_work_experience.application_form
    end
  end
end
