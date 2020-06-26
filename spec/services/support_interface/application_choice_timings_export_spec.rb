require 'rails_helper'

RSpec.describe SupportInterface::ApplicationChoiceTimingsExport, with_audited: true do
  describe '#application_choices' do
    it 'returns application choices with timings' do
      unsubmitted_form = create(:application_form)
      create(:application_choice, status: :unsubmitted, application_form: unsubmitted_form)
      create(:completed_application_form, application_choices_count: 2)

      choices = described_class.new.application_choices
      expect(choices.size).to eq(3)
    end
  end
end
