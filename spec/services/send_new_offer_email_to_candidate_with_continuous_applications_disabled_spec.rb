# This file can be dropped along with the continuous applications feature flag. The new functionality is tested in `send_new_offer_email_to_candidate_spec.rb`

require 'rails_helper'

RSpec.describe SendNewOfferEmailToCandidate, continuous_applications: false do
  describe '#call' do
    def setup_application
      @candidate = create(:candidate)
      @application_form = create(
        :application_form,
        candidate: @candidate,
      )
      course_option = create(:course_option)
      @application_choice = @application_form.application_choices.create(
        application_form: @application_form,
        original_course_option: course_option,
        course_option:,
        current_course_option: course_option,
        status: :offer,
      )
    end

    context 'when there is a single offer' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_single_offer).and_return(mail)
        setup_application
      end

      it 'sends new offer email for single offer case' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_single_offer).with(@application_choice)
      end
    end

    context 'when there are multiple offers' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_multiple_offers).and_return(mail)
        setup_application
        other_course_option = create(:course_option)
        @application_form.application_choices.create(
          application_form: @application_form,
          original_course_option: other_course_option,
          course_option: other_course_option,
          current_course_option: other_course_option,
          status: :offer,
        )
      end

      it 'sends new offer email for multiple offers case' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_multiple_offers).with(@application_choice)
      end
    end

    context 'when there are other choices in the awaiting_provider_decision state' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_decisions_pending).and_return(mail)
        setup_application
        other_course_option = create(:course_option)
        @application_form.application_choices.create(
          application_form: @application_form,
          original_course_option: other_course_option,
          course_option: other_course_option,
          current_course_option: other_course_option,
          status: :awaiting_provider_decision,
        )
      end

      it 'sends new offer email for pending decision case' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_decisions_pending).with(@application_choice)
      end
    end

    context 'when there are other choices in the interviewing state' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_decisions_pending).and_return(mail)
        setup_application
        other_course_option = create(:course_option)
        @application_form.application_choices.create(
          application_form: @application_form,
          original_course_option: other_course_option,
          course_option: other_course_option,
          current_course_option: other_course_option,
          status: :interviewing,
        )
      end

      it 'sends new offer email for pending decision case' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_decisions_pending).with(@application_choice)
      end
    end
  end
end
