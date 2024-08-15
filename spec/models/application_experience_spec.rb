require 'rails_helper'

RSpec.describe ApplicationExperience do
  it { is_expected.to belong_to(:experienceable).touch(true) }

  it { is_expected.to validate_presence_of(:role) }
  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:start_date) }

  describe 'auditing', :with_audited do
    it { is_expected.to be_audited.associated_with :experienceable }
  end

  describe '#application_form' do
    it 'returns the application_form from experienceable' do
      application_form = create(:application_form)
      experience = build(
        :application_work_experience,
        experienceable: application_form,
      )

      expect(experience.application_form).to eq(application_form)
    end

    context 'when experienceable is not ApplicationForm' do
      it 'returns nil' do
        application_choice = create(:application_choice)
        experience = build(
          :application_work_experience,
          experienceable: application_choice,
        )

        expect(experience.application_form).to be_nil
      end
    end
  end
end
