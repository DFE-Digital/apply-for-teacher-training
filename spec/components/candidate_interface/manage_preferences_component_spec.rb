require 'rails_helper'

RSpec.describe CandidateInterface::ManagePreferencesComponent, type: :component do
  include Rails.application.routes.url_helpers

  describe '#render' do
    context 'when sent applications' do
      it 'renders the component' do
        application_form = create(:application_form, :with_accepted_offer)

        component = described_class.new(application_form:)
        result = render_inline(component)

        expect(result.to_html).not_to be_blank
      end
    end

    context 'when no sent applications' do
      it 'renders the component' do
        application_form = create(:application_form)

        component = described_class.new(application_form:)
        result = render_inline(component)

        expect(result.to_html).to be_blank
      end
    end

    context 'when application is withdrawn and no longer training to teach' do
      it 'does not render the Change link' do
        application_form = create(:application_form)
        _preference = create(
          :candidate_preference,
          status: 'published',
          pool_status: 'opt_in',
          application_form:,
        )

        withdrawn_choice = create(:application_choice, status: 'withdrawn', application_form:)
        create(:withdrawal_reason, application_choice: withdrawn_choice, reason: 'do-not-want-to-train-anymore.another_career_path_or_accepted_a_job_offer')

        render_inline(described_class.new(application_form:))

        expect(page).to have_no_link('Change')
      end
    end

    context 'when application is withdrawn but still training to teach' do
      it 'renders the Change link' do
        application_form = create(:application_form)
        _preference = create(
          :candidate_preference,
          status: 'published',
          pool_status: 'opt_in',
          application_form:,
        )

        withdrawn_choice = create(:application_choice, status: 'withdrawn', application_form:)
        create(:withdrawal_reason, application_choice: withdrawn_choice, reason: 'applying_to_another_provider.accepted_another_offer')

        render_inline(described_class.new(application_form:))

        expect(page).to have_link('Change')
      end
    end
  end

  describe '#pool_opt_in?' do
    it 'returns true when candidate has opted in' do
      preference = create(
        :candidate_preference,
        pool_status: 'opt_in',
        status: 'published',
        application_form: create(:application_form),
      )

      component = described_class.new(application_form: preference.application_form)
      expect(component.pool_opt_in?).to be true
    end

    it 'returns false when candidate has opted out' do
      preference = create(
        :candidate_preference,
        pool_status: 'opt_out',
        status: 'published',
        application_form: create(:application_form),
      )

      component = described_class.new(application_form: preference.application_form)
      expect(component.pool_opt_in?).to be false
    end
  end

  describe '#path_to_change_preferences' do
    it 'returns the published show path if the candidate has a published preference' do
      preference = create(
        :candidate_preference,
        status: 'published',
        application_form: create(:application_form, :with_accepted_offer),
      )

      render_inline(
        described_class.new(application_form: preference.application_form),
      )

      expect(page).to have_link(
        'Change',
        href: candidate_interface_draft_preference_publish_preferences_path(preference),
      )
    end

    it 'returns the new opt in path if the candidate does not have a published preference' do
      preference = create(
        :candidate_preference,
        status: 'draft',
        application_form: create(:application_form, :with_accepted_offer),
      )

      render_inline(
        described_class.new(application_form: preference.application_form),
      )

      expect(page).to have_link(
        'Change',
        href: new_candidate_interface_pool_opt_in_path,
      )
    end

    it 'returns the edit opt in path if the published preference is opted out' do
      preference = create(
        :candidate_preference,
        status: 'published',
        pool_status: 'opt_out',
        application_form: create(:application_form, :with_accepted_offer),
      )

      render_inline(
        described_class.new(application_form: preference.application_form),
      )

      expect(page).to have_link(
        'Change',
        href: edit_candidate_interface_pool_opt_in_path(
          preference,
        ),
      )
    end
  end
end
