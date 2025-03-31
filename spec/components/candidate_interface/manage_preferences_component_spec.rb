require 'rails_helper'

RSpec.describe CandidateInterface::ManagePreferencesComponent, type: :component do
  include Rails.application.routes.url_helpers

  describe '#render' do
    context 'when candidate preference feature flag is enabled' do
      it 'renders the component' do
        FeatureFlag.activate(:candidate_preferences)
        application_form = create(:application_form, :with_accepted_offer)

        component = described_class.new(current_candidate: application_form.candidate, application_form:)
        result = render_inline(component)

        expect(result.to_html).not_to be_blank
      end
    end

    context 'when candidate preference feature flag is not enabled' do
      it 'renders the component' do
        application_form = create(:application_form, :with_accepted_offer)

        component = described_class.new(current_candidate: application_form.candidate, application_form:)
        result = render_inline(component)

        expect(result.to_html).to be_blank
      end
    end

    context 'when candidate preference feature flag is enabled but no sent applications' do
      it 'renders the component' do
        FeatureFlag.activate(:candidate_preferences)
        application_form = create(:application_form)

        component = described_class.new(current_candidate: application_form.candidate, application_form:)
        result = render_inline(component)

        expect(result.to_html).to be_blank
      end
    end
  end

  describe '#pool_opt_in?' do
    it 'returns true when candidate has opted in' do
      candidate = create(:candidate)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'published',
        candidate:,
      )
      application_form = build(:application_form)

      component = described_class.new(current_candidate: candidate, application_form:)
      expect(component.pool_opt_in?).to be true
    end

    it 'returns false when candidate has opted out' do
      candidate = create(:candidate)
      _preference = create(
        :candidate_preference,
        pool_status: 'opt_out',
        status: 'published',
        candidate:,
      )
      application_form = build(:application_form)

      component = described_class.new(current_candidate: candidate, application_form:)
      expect(component.pool_opt_in?).to be false
    end
  end

  describe '#path_to_change_preferences' do
    it 'returns the published show path if the candidate has a published preference' do
      FeatureFlag.activate(:candidate_preferences)
      candidate = create(:candidate)
      preference = create(
        :candidate_preference,
        status: 'published',
        candidate:,
      )
      application_form = create(:application_form, :with_accepted_offer)

      render_inline(
        described_class.new(current_candidate: candidate, application_form:),
      )

      expect(page).to have_link(
        'Change your sharing and location settings',
        href: candidate_interface_draft_preference_publish_preferences_path(preference),
      )
    end

    it 'returns the new opt in path if the candidate does not have a published preference' do
      FeatureFlag.activate(:candidate_preferences)
      candidate = create(:candidate)
      _preference = create(
        :candidate_preference,
        status: 'draft',
        candidate:,
      )
      application_form = create(:application_form, :with_accepted_offer)

      render_inline(
        described_class.new(current_candidate: candidate, application_form:),
      )

      expect(page).to have_link(
        'Change your sharing and location settings',
        href: new_candidate_interface_pool_opt_in_path,
      )
    end
  end
end
