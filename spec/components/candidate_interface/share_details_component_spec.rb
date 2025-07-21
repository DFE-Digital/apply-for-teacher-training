require 'rails_helper'

RSpec.describe CandidateInterface::ShareDetailsComponent, type: :component do
  include Rails.application.routes.url_helpers

  before { FeatureFlag.activate(:candidate_preferences) }

  describe '#render' do
    context 'when submit_application is true' do
      it 'renders the component with continue button to new pool opt in' do
        candidate = build(:candidate)
        render_inline(described_class.new(candidate, submit_application: true))

        expected_path = new_candidate_interface_pool_opt_in_path

        expect(page).to have_button('Continue')
        expect(page).to have_css("form[action='#{expected_path}']")
      end
    end

    context 'when submit_application is false' do
      context 'when candidate has published preference' do
        it 'renders the component with continue link to published preference show' do
          candidate = create(:candidate)
          preference = create(
            :candidate_preference,
            candidate:,
            status: 'published',
          )

          render_inline(described_class.new(candidate))

          expect(page).to have_link(
            'Update your preferences',
            href: candidate_interface_draft_preference_publish_preferences_path(preference),
          )
        end
      end

      context 'when candidate has no published preference' do
        it 'renders the component with continue link to new pool opt in' do
          candidate = create(:candidate)
          _preference = create(
            :candidate_preference,
            candidate:,
            status: 'draft',
          )

          render_inline(described_class.new(candidate))

          expect(page).to have_link(
            'Update your preferences',
            href: new_candidate_interface_pool_opt_in_path,
          )
        end
      end

      context 'when candidate has published preference but opted out' do
        it 'renders the component with continue link to edit pool opt in' do
          candidate = create(:candidate)
          preference = create(
            :candidate_preference,
            candidate:,
            status: 'published',
            pool_status: 'opt_out',
          )

          render_inline(described_class.new(candidate))

          expect(page).to have_link(
            'Update your preferences',
            href: edit_candidate_interface_pool_opt_in_path(preference),
          )
        end
      end
    end
  end
end
