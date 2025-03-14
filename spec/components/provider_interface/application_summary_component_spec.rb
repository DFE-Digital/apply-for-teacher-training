require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationSummaryComponent do
  describe '#rows' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form) }
    let(:application_form) { application_choice.application_form }
    let(:expected) do
      [
        { key: 'Application number', value: application_choice.id },
        { key: 'Submitted', value: application_choice.sent_to_provider_at.to_fs(:govuk_date_and_time) },
        { key: 'Recruitment cycle', value: application_form.recruitment_cycle_timetable.cycle_range_name_with_current_indicator },
      ]
    end

    subject { described_class.new(application_choice:).rows }

    it { is_expected.to match_array(expected) }
  end
end
