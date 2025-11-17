require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationVisibilityComponent, type: :component do
  describe '#render?' do
    let(:application_form) { create(:application_form) }

    subject(:component) { described_class.new(application_form:) }

    context 'when application has not been submitted' do
      before { allow(application_form).to receive(:submitted_applications?).and_return(false) }

      it 'returns false' do
        expect(component.render?).to be false
      end
    end

    context 'when pool_opt_out_or_no_preference is true' do
      before do
        create(:candidate_preference, pool_status: 'opt_out', status: 'published', application_form:)
        allow(application_form).to receive(:submitted_applications?).and_return(true)
      end

      it 'returns true' do
        expect(component.render?).to be true
      end
    end

    context 'when visible_to_providers is true' do
      before do
        create(:candidate_pool_application, application_form:, candidate: application_form.candidate)
        allow(application_form).to receive(:submitted_applications?).and_return(true)
      end

      it 'returns true' do
        expect(component.render?).to be true
      end
    end

    context 'when waiting_for_provider_decision is true' do
      before do
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:candidate_preference, pool_status: 'opt_in', status: 'published', application_form:)
        allow(application_form).to receive(:submitted_applications?).and_return(true)
      end

      it 'returns true' do
        expect(component.render?).to be true
      end
    end

    context 'when withdrawn_no_longer_training is true' do
      before do
        withdrawn_choice = create(:application_choice, :withdrawn, application_form:)
        create(:withdrawal_reason, application_choice: withdrawn_choice, reason: 'do-not-want-to-train-anymore.another_career_path_or_accepted_a_job_offer')
        create(:candidate_preference, pool_status: 'opt_in', status: 'published', application_form:)
        allow(application_form).to receive(:submitted_applications?).and_return(true)
      end

      it 'returns true' do
        expect(component.render?).to be true
      end
    end

    context 'when offer is true' do
      before do
        create(:application_choice, :offered, application_form:)
        create(:candidate_preference, pool_status: 'opt_in', status: 'published', application_form:)
        allow(application_form).to receive(:submitted_applications?).and_return(true)
      end

      it 'returns true' do
        expect(component.render?).to be true
      end
    end

    context 'when none of the visibility conditions are met' do
      before do
        create(:candidate_preference, pool_status: 'opt_in', status: 'published', application_form:)
        allow(application_form).to receive(:submitted_applications?).and_return(true)
      end

      it 'returns false' do
        expect(component.render?).to be false
      end
    end
  end

  describe '#pool_opt_in?' do
    it 'returns true when candidate has opted in' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'published',
        application_form:,
      )

      component = described_class.new(application_form:)
      expect(component.pool_opt_in?).to be true
    end

    it 'returns false when candidate has opted out' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_out',
        status: 'published',
        application_form:,
      )

      component = described_class.new(application_form:)
      expect(component.pool_opt_in?).to be false
    end
  end

  describe '#pool_opt_out_or_no_preference?' do
    it 'returns true when candidate has opted out' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_out',
        status: 'published',
        application_form:,
      )

      component = described_class.new(application_form:)
      expect(component.pool_opt_out_or_no_preference?).to be true
    end

    it 'returns true when candidate has no published preference' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'draft',
        application_form:,
      )

      component = described_class.new(application_form:)
      expect(component.pool_opt_out_or_no_preference?).to be true
    end

    it 'returns false when candidate has opted in' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'published',
        application_form:,
      )

      component = described_class.new(application_form:)
      expect(component.pool_opt_out_or_no_preference?).to be false
    end
  end

  describe '#waiting_for_provider_decision?' do
    it 'displays opted in but not visible to providers if the application form is opted in and has choices awaiting decision' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'published',
        application_form:,
      )
      _application_choice_awaiting_provider_decision = create(:application_choice, :awaiting_provider_decision, application_form:)

      render_inline(described_class.new(application_form:))

      expect(page).to have_content('Your application details are not currently visible to other providers. You have submitted applications that are waiting for a decision.')
      expect(page).to have_content('When all your applications are rejected, withdrawn or inactive, providers will be able to view your application details and invite you to apply. However, you should continue to apply to courses yourself. Do not wait to be invited.')
    end

    it 'displays opted in but not visible to providers if the application form is opted in and has choices with a status of interviewing' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'published',
        application_form:,
      )
      _application_choice_awaiting_provider_decision = create(:application_choice, :interviewing, application_form:)

      render_inline(described_class.new(application_form:))

      expect(page).to have_content('Your application details are not currently visible to other providers. You have submitted applications that are waiting for a decision.')
      expect(page).to have_content('When all your applications are rejected, withdrawn or inactive, providers will be able to view your application details and invite you to apply. However, you should continue to apply to courses yourself. Do not wait to be invited.')
    end
  end

  describe '#offer?' do
    it 'displays opted in but not visible to providers if the application form is opted in and has an offer' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'published',
        application_form:,
      )
      _application_choice_awaiting_provider_decision = create(:application_choice, :offered, application_form:)

      render_inline(described_class.new(application_form:))

      expect(page).to have_content('Your application details are not currently visible to other providers. You have offers that you need to respond to.')
      expect(page).to have_content('When all your applications are rejected, withdrawn or inactive, providers will be able to view your application details and invite you to apply. However, you should continue to apply to courses yourself. Do not wait to be invited.')
    end
  end

  describe '#visible_to_providers?' do
    it 'displays opted in and visible if the candidate is in the pool' do
      application_form = create(:application_form)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'published',
        application_form:,
      )
      _application_choice = create(:application_choice, :withdrawn, application_form:)
      create(:candidate_pool_application, application_form:, candidate: application_form.candidate)

      render_inline(described_class.new(application_form:))

      expect(page).to have_content('Your application details are currently visible to other providers. You have no submitted applications that are waiting for a decision.')
      expect(page).to have_content('Because all your applications are rejected, withdrawn or inactive, providers can view your application details and invite you to apply. However, you should continue to apply to courses yourself. Do not wait to be invited.')
    end
  end

  describe '#application_form.withdrawn_no_longer_training?' do
    context 'when application has a withdrawn choice with reason of not training to teach anymore' do
      it 'renders the withdrawn_no_longer_training content' do
        application_form = create(:application_form)
        _preference = create(
          :candidate_preference,
          pool_status: 'opt_in',
          status: 'published',
          application_form:,
        )
        withdrawn_offer = create(:application_choice, :withdrawn, application_form:)
        create(:withdrawal_reason, application_choice: withdrawn_offer, reason: 'do-not-want-to-train-anymore.another_career_path_or_accepted_a_job_offer')

        render_inline(described_class.new(application_form:))

        expect(page).to have_content('Your application details are not currently visible to other providers.')
        expect(page).to have_content("You have withdrawn an application with the reason 'I do not want to train to teach anymore'.")
        expect(page).to have_link('contact support', href: 'mailto:becomingateacher@digital.education.gov.uk')
      end
    end
  end
end
