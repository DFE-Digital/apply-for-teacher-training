require 'rails_helper'

RSpec.describe SubmitApplication do
  describe 'Submit an application' do
    let(:application_form) { create(:application_form) }

    before do
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
    end

    it 'updates the application to Submitted' do
      SubmitApplication.new(application_form).call
      expect(application_form.application_choices[0]).to be_awaiting_references
      expect(application_form.application_choices[1]).to be_awaiting_references
      expect(application_form.support_reference).not_to be_empty
    end

    context 'sending emails' do
      let(:mailer) { double }

      before { allow(mailer).to receive(:deliver_now) }

      it 'sends an application submitted email' do
        allow(CandidateMailer).to receive(:submit_application_email).and_return(mailer)

        SubmitApplication.new(application_form).call
        expect(CandidateMailer).to have_received(:submit_application_email).with(application_form)
        expect(mailer).to have_received(:deliver_now)
      end

      it 'sends a reference request email to each referee' do
        allow(RefereeMailer).to receive(:reference_request_email).and_return(mailer)

        SubmitApplication.new(application_form).call
        application_form.references.each do |r|
          expect(RefereeMailer).to have_received(reference_request_email).with(application_form, r)
          expect(mailer).to have_received(:deliver_now)
        end
      end
    end

    it 'sets application_form.submitted_at' do
      Timecop.freeze(Time.zone.local(2019, 11, 11, 15, 0, 0)) do
        expected_edit_by = Time.zone.local(2019, 11, 18).end_of_day
        SubmitApplication.new(application_form).call

        expect(application_form.submitted_at).to eq Time.zone.now
        expect(application_form.application_choices[0].edit_by).to eq expected_edit_by
        expect(application_form.application_choices[1].edit_by).to eq expected_edit_by
      end
    end
  end
end
