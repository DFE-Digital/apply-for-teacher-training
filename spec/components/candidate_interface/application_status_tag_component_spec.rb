require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationStatusTagComponent do
  let(:course) { create(:course) }

  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      render_inline CandidateInterface::ApplicationStatusTagComponent.new(application_choice: create(:application_choice, course: course, status: state_name))
    end

    context 'when the application choice is in the application_not_sent state' do
      it 'tells the candidate why their application was not sent to their provider(s)' do
        application_choice = create(:application_choice, :application_not_sent, course: course)
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.text).to include('Your application was not sent for this course because references were not given before the deadline.')
      end
    end

    context 'when the application choice is in the offer_deferred state' do
      it 'tells the candidate when their course will start' do
        application_choice = create(:application_choice, :offer_deferred, course: course)
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.text).to include("Your training will now start in #{(application_choice.course.start_date + 1.year).strftime('%B %Y')}.")
      end
    end
  end
end
