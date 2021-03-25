require 'rails_helper'

RSpec.describe MakeAnOffer, sidekiq: true do
  include CourseOptionHelpers
  let(:user) { SupportUser.new }
  let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
  # necessary to create_course_option_for_provider as the default course in the default course_option
  # is not open_on_apply
  let(:valid_course_option) { course_option_for_provider(provider: application_choice.course_option.provider) }

  describe 'conditions validation' do
    it 'accepts nil conditions' do
      decision = MakeAnOffer.new(
        actor: user,
        application_choice: application_choice,
        course_option: valid_course_option,
        offer_conditions: nil,
      )

      expect(decision).to be_valid
    end

    it 'limits the number of conditions to 20' do
      decision = MakeAnOffer.new(
        actor: user,
        application_choice: application_choice,
        course_option: valid_course_option,
        offer_conditions: Array.new(21) { 'a condition' },
      )

      expect(decision).not_to be_valid
    end

    it 'limits the length of individual further_conditions to 255 characters' do
      decision = MakeAnOffer.new(
        actor: user,
        application_choice: application_choice,
        course_option: valid_course_option,
        further_conditions: { further_conditions2: 'a' * 256 },
      )

      expect(decision).not_to be_valid
    end
  end

  describe '#offer_conditions' do
    context 'when there are no offer conditions' do
      it 'returns an empty array' do
        decision = MakeAnOffer.new(
          actor: user,
          application_choice: application_choice,
          course_option: valid_course_option,
          offer_conditions: [],
          )
        expect(decision.offer_conditions).to eq([])
      end
    end

    context 'when no offer conditions are specified' do
      it 'returns a combination of standard and further conditions' do
        decision = MakeAnOffer.new(
          actor: user,
          application_choice: application_choice,
          course_option: valid_course_option,
          further_conditions: []
          )
        expect(decision.offer_conditions).to eq(MakeAnOffer::STANDARD_CONDITIONS)
      end
    end
  end

  describe '#save' do
    it 'sets the offered_at date' do
      offer = MakeAnOffer.new(actor: user, application_choice: application_choice, course_option: valid_course_option)

      Timecop.freeze do
        offer.save

        expect(application_choice.offered_at).to eq(Time.zone.now)
      end
    end

    it 'sends an email to the candidate' do
      offer = MakeAnOffer.new(actor: user, application_choice: application_choice, course_option: valid_course_option)

      offer.save

      expect(CandidateMailer.deliveries.count).to be 1
    end

    it 'sets the offered_course_option_id to the offered_course_option’s id' do
      offer = MakeAnOffer.new(actor: user, application_choice: application_choice, course_option: valid_course_option)

      offer.save

      expect(application_choice.offered_course_option_id).to eq valid_course_option.id
    end

    it 'sets the decline_by_default_at date' do
      MakeAnOffer.new(actor: user, application_choice: application_choice, course_option: valid_course_option).save
      application_choice.reload

      expect(application_choice.decline_by_default_at).not_to be_nil
      expect(application_choice.decline_by_default_days).not_to be_nil
    end
  end

  describe 'course option validation' do
    it 'checks the course is open on apply' do
      offer = MakeAnOffer.new(actor: user, application_choice: application_choice, course_option: create(:course_option))

      offer.valid?

      expect(offer.errors[:course_option]).to include('is not open for applications via the Apply service')
    end

    it 'checks the course is present' do
      offer = MakeAnOffer.new(actor: user, application_choice: application_choice, course_option: nil)

      offer.valid?

      expect(offer.errors[:course_option]).to include('could not be found')
    end
  end

  describe 'authorisation' do
    it 'raises error if actor is not associated with the right provider' do
      application_choice = create(:application_choice, status: :awaiting_provider_decision)
      unrelated_user = create(:provider_user, :with_provider)
      new_offer = MakeAnOffer.new(actor: unrelated_user, application_choice: application_choice, course_option: valid_course_option)
      expect { new_offer.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end

    it 'raises error if actor does not have make_decisions permission' do
      unauthorised_user = create(:provider_user, :with_provider)
      course = create(:course, :open_on_apply, provider: unauthorised_user.providers.first)
      course_option = create(:course_option, course: course)

      application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
      new_offer = MakeAnOffer.new(actor: unauthorised_user, application_choice: application_choice, course_option: course_option)
      expect { new_offer.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end

    it 'does not raise error if actor is authorised' do
      related_user = create(:provider_user, :with_provider, :with_make_decisions)
      course = create(:course, provider: related_user.providers.first)
      course_option = create(:course_option, course: course)

      application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
      new_offer = MakeAnOffer.new(actor: related_user, application_choice: application_choice, course_option: course_option)
      expect { new_offer.save }.not_to raise_error
    end
  end

  describe 'audits', with_audited: true do
    it 'generates an audit event combining status change with offered_course_option_id' do
      offer = MakeAnOffer.new(actor: user, application_choice: application_choice, course_option: valid_course_option)

      offer.save

      audit_with_status_change = application_choice.reload.audits.find_by('jsonb_exists(audited_changes, ?)', 'status')
      expect(audit_with_status_change.audited_changes).to have_key('offered_course_option_id')
    end
  end
end
