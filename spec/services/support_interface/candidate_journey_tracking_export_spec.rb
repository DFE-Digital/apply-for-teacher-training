require 'rails_helper'

RSpec.describe SupportInterface::CandidateJourneyTrackingExport, with_audited: true do
  it_behaves_like 'a data export'

  describe '#data_for_export' do
    around do |example|
      Timecop.freeze { example.run }
    end

    it 'returns application choices with timings' do
      unsubmitted_form = create(:application_form)
      create(:application_choice, status: :unsubmitted, application_form: unsubmitted_form)
      create(:completed_application_form, application_choices_count: 2)

      choices = Bullet.profile { described_class.new.data_for_export }
      expect(choices.size).to eq(3)

      expect(choices[0][:form_not_started]).to eq(Time.zone.now.iso8601)
    end
  end
end
