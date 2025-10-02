require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationVisibilityComponent, type: :component do
  describe '#render' do
    context 'when candidate preference feature flag is enabled' do
      it 'renders the component' do
        FeatureFlag.activate(:candidate_preferences)
        application_form = create(:application_form, :with_accepted_offer)

        component = described_class.new(application_form:)
        result = render_inline(component)

        expect(result.to_html).not_to be_blank
      end
    end

    context 'when candidate preference feature flag is not enabled' do
      it 'renders the component' do
        FeatureFlag.deactivate(:candidate_preferences)
        application_form = create(:application_form, :with_accepted_offer)

        component = described_class.new(application_form:)
        result = render_inline(component)

        expect(result.to_html).to be_blank
      end
    end

    context 'when candidate preference feature flag is enabled but no sent applications' do
      it 'renders the component' do
        FeatureFlag.activate(:candidate_preferences)
        application_form = create(:application_form)

        component = described_class.new(application_form:)
        result = render_inline(component)

        expect(result.to_html).to be_blank
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

  describe 'waiting_for_provider_decision?' do
    it 'displays opted in but not visible to providers if the application form is opted in and has choices awaiting decision' do
      FeatureFlag.activate(:candidate_preferences)
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
      FeatureFlag.activate(:candidate_preferences)
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

  describe 'offer?' do
    it 'displays opted in but not visible to providers if the application form is opted in and has an offer' do
      FeatureFlag.activate(:candidate_preferences)
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

  describe 'visible_to_providers?' do
    it 'displays opted in and visible if the candidate is in the pool' do
      FeatureFlag.activate(:candidate_preferences)
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
end
