require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationStatusTagComponent do
  let(:course) { create(:course) }

  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      render_inline described_class.new(application_choice: create(:application_choice, course: course, status: state_name))
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

        expect(result.text).to include("Your training will now start in #{(application_choice.course.start_date + 1.year).to_s(:month_and_year)}.")
      end

      context 'when the application choice is in the pending_conditions state' do
        it 'provides guidance on how to defer your application' do
          application_choice = create(:application_choice, :pending_conditions, course: course)
          result = render_inline(described_class.new(application_choice: application_choice))

          expect(result.text).to include('Some providers allow you to defer your offer. This means that you could start your course a year later.')
        end
      end

      context 'when the application choice is in the recruited state' do
        it 'provides guidance on how to defer your application' do
          application_choice = create(:application_choice, :recruited, course: course)
          result = render_inline(described_class.new(application_choice: application_choice))

          expect(result.text).to include('Some providers allow you to defer your offer. This means that you could start your course a year later.')
        end
      end

      context 'when the application choice is in the offer state' do
        it 'provides guidance on how to defer your application' do
          application_choice = create(:application_choice, :offer, course: course)
          result = render_inline(described_class.new(application_choice: application_choice))

          expect(result.text).to include('If your provider agrees to defer your offer, you’ll need to accept the offer on your account first.')
        end
      end
    end
  end

  context 'provider withdraws an application choice on behalf of the candidate' do
    it 'displays additional guidance' do
      application_choice = create(:application_choice, :with_offer)

      allow(application_choice).to receive(:withdrawn_at_candidates_request?).and_return(true)

      result = render_inline(described_class.new(application_choice: application_choice))

      expect(result.text).to include(
        'You requested to withdraw your application. If you did not request this, email becomingateacher@digital.education.gov.uk.',
      )
    end
  end

  context 'candidate withdraws their own application' do
    it 'does not display additional guidance' do
      application_choice = create(:application_choice, :with_offer)

      allow(application_choice).to receive(:withdrawn_at_candidates_request?).and_return(false)

      result = render_inline(described_class.new(application_choice: application_choice.reload))

      expect(result.text).not_to include(
        'You requested to withdraw your application. If you did not request this, email becomingateacher@digital.education.gov.uk.',
      )
    end
  end
end
