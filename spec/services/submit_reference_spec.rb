require 'rails_helper'

RSpec.describe SubmitReference, sidekiq: true do
  describe '#save!' do
    xit 'updates the reference to "feedback_provided" and sets `feedback_provided_at` to the current time' do
      Timecop.freeze do
        application_choice = create(:application_choice, status: :unsubmitted)
        application_form = application_choice.application_form
        reference_one = create(:reference, :feedback_requested)
        reference_two = create(:reference, :feedback_requested, application_form: reference_one.application_form)

        described_class.new(reference: reference_one).save!
        described_class.new(reference: reference_two).save!

        expect(reference_one).to be_feedback_provided
        expect(reference_one.feedback_provided_at).to eq Time.zone.now
        expect(reference_two).to be_feedback_provided
        expect(reference_two.feedback_provided_at).to eq Time.zone.now
        expect(reference_one.selected).to be false
        expect(reference_two.selected).to be false
        expect(application_form.reload.application_choices).to all(be_unsubmitted)
      end
    end

    context 'when overriding the selected from a reference' do
      xit 'uses the selected on initialize' do
        Timecop.freeze do
          reference_one = create(:reference, :feedback_requested)
          reference_two = create(:reference, :feedback_requested, application_form: reference_one.application_form)

          described_class.new(reference: reference_one, selected: true).save!
          described_class.new(reference: reference_two, selected: false).save!

          expect(reference_one.selected).to be true
          expect(reference_two.selected).to be false
        end
      end
    end

    context 'when new references feature flag is enabled' do
      before do
        FeatureFlag.activate(:new_references_flow_providers)
      end

      it 'sends email to provider users' do
        application_form = create(:application_form, :minimum_info)
        create(:reference, :feedback_provided, application_form:)
        create(:reference, :feedback_requested, application_form:)
        reference = create(:reference, :feedback_requested, application_form:)
        application_choice = create(:application_choice, :with_accepted_offer, application_form:)

        provider_user = create(:provider_user, :with_notifications_enabled, providers: [application_choice.course.provider])

        create(:provider_user, :with_notifications_enabled, providers: [create(:provider)])

        create(:provider_user_notification_preferences, :all_off, provider_user: create(:provider_user, providers: [application_choice.course.provider]))

        described_class.new(reference: reference).save!

        expect(reference).to be_feedback_provided

        expect(
          ActionMailer::Base.deliveries.map(&:to).flatten,
        ).to eq([
          application_form.candidate.email_address,
          reference.email_address,
          provider_user.email_address,
        ])

        expect(ActionMailer::Base.deliveries.last.subject).to include(
          "#{application_form.full_name}’s second reference received",
        )
      end
    end

    context 'when the second reference is received' do
      xit 'does not alter the state of any outstanding references' do
        application_form = create(:application_form)
        reference1 = create(:reference, :feedback_requested, application_form:)
        reference2 = create(:reference, :feedback_requested, application_form:)
        reference3 = create(:reference, :feedback_refused, application_form:)
        reference4 = create(:reference, :feedback_requested, application_form:)

        described_class.new(reference: reference1).save!
        described_class.new(reference: reference2).save!

        expect(reference1).to be_feedback_provided
        expect(reference2).to be_feedback_provided
        expect(reference3.reload).to be_feedback_refused
        expect(reference4.reload).to be_feedback_requested
      end
    end
  end
end
