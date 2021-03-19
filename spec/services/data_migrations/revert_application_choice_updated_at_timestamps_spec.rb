require 'rails_helper'

RSpec.describe DataMigrations::RevertApplicationChoiceUpdatedAtTimestamps do
  describe '#change' do
    it 'updates the updated_at for application_choices in the desired state to the previous audits created_at', with_audited: true do
      targeted_update_time = Time.zone.local(2021, 3, 17, 12, 45)
      Timecop.freeze(targeted_update_time - 1.day) do
        @application_form = create(:completed_application_form, second_nationality: '')
        @stale_application_choice = create(:application_choice, :awaiting_provider_decision, application_form: @application_form)
        @active_application_choice = create(:application_choice, :awaiting_provider_decision, application_form: @application_form)
        @stale_application_choice.offer!
      end

      Timecop.freeze(targeted_update_time) do
        @application_form.update!(second_nationality: nil)
      end

      Timecop.freeze(targeted_update_time + 1.day) do
        @active_application_choice.offer!
      end

      described_class.new.change

      expect(@stale_application_choice.updated_at).to eq targeted_update_time - 1.day
      expect(@active_application_choice.updated_at).to eq targeted_update_time + 1.day
    end
  end
end
