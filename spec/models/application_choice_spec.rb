require 'rails_helper'

RSpec.describe ApplicationChoice, type: :model do
  describe '#create' do
    it 'starts in the "unsubmitted" status' do
      course_option = create(:course_option)
      application_choice = ApplicationChoice.create!(
        application_form: create(:application_form),
        course_option: course_option,
      )

      expect(application_choice).to be_unsubmitted
    end

    it 'allows a different status to be set' do
      course_option = create(:course_option)
      application_choice = ApplicationChoice.create!(
        status: 'application_complete',
        application_form: create(:application_form),
        course_option: course_option,
      )

      expect(application_choice).to be_application_complete
    end
  end

  describe 'auditing' do
    it 'creates audit entries' do
      application_choice = create :application_choice
      expect(application_choice.audits.count).to eq 1
      application_choice.update!(personal_statement: 'hello again')
      expect(application_choice.audits.count).to eq 2
    end

    it 'creates an associated object in each audit record' do
      application_choice = create :application_choice
      expect(application_choice.audits.last.associated).to eq application_choice.application_form
    end

    it 'audit record can be attributed to a candidate' do
      candidate = create :candidate
      application_choice = Audited.audit_class.as_user(candidate) do
        create :application_choice
      end
      expect(application_choice.audits.last.user).to eq candidate
    end
  end
end
