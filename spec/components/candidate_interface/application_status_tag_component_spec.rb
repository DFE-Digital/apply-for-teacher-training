require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationStatusTagComponent do
  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      render_inline CandidateInterface::ApplicationStatusTagComponent.new(application_choice: FactoryBot.build_stubbed(:application_choice, status: state_name))
    end

    context 'when the application choice is in the application_not_sent state' do
      it 'tells the candidate why their application was not sent to their provider(s)' do
        application_choice = build_stubbed(:application_choice, :application_not_sent)
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.text).to include('Your application was not sent for this course because references were not given before the deadline.')
      end
    end
  end
end
