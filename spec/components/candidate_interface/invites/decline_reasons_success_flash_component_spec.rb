require 'rails_helper'

RSpec.describe CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent do
  include Rails.application.routes.url_helpers

  it 'renders the component with the invite' do
    candidate = build_stubbed(:candidate)
    course = build_stubbed(:course)
    invite = build_stubbed(:pool_invite, candidate:, course:)

    result = render_inline(described_class.new(invite:))

    expect(result).to have_text('If you have changed your mind you can still apply to this course')
    expect(result).to have_link('apply to this course', href: candidate_interface_course_choices_course_confirm_selection_path(course))
  end

  describe '#change_preferences_text_component' do
    it 'returns nil when no decline reasons are present' do
      invite = build_stubbed(:pool_invite, published_invite_decline_reasons: [])

      component = described_class.new(invite:)

      expect(component.change_preferences_text_component).to be_nil
    end

    context 'when decline reasons include no longer interested' do
      it 'returns NoLongerInterestedComponent' do
        invite = build_stubbed(:pool_invite, published_invite_decline_reasons: [build_stubbed(:pool_invite_decline_reason, reason: 'no_longer_interested')])

        component = described_class.new(invite:)

        expect(component.change_preferences_text_component).to be_a(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::NoLongerInterestedComponent)
      end
    end

    context 'when decline reasons include only salaried and location not convenient' do
      it 'returns UpdateLocationAndFundingPreferencesComponent' do
        invite = build_stubbed(:pool_invite, published_invite_decline_reasons: [
          build_stubbed(:pool_invite_decline_reason, reason: 'only_salaried'),
          build_stubbed(:pool_invite_decline_reason, reason: 'location_not_convenient'),
        ])

        component = described_class.new(invite:)

        expect(component.change_preferences_text_component).to be_a(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::UpdateLocationAndFundingPreferencesComponent)
      end
    end

    context 'when decline reasons include only salaried' do
      it 'returns ChangeFundingPreferencesComponent' do
        invite = build_stubbed(:pool_invite, published_invite_decline_reasons: [build_stubbed(:pool_invite_decline_reason, reason: 'only_salaried')])

        component = described_class.new(invite:)

        expect(component.change_preferences_text_component).to be_a(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::ChangeFundingPreferencesComponent)
      end
    end

    context 'when decline reasons include location not convenient' do
      it 'returns ChangeLocationPreferencesComponent' do
        invite = build_stubbed(:pool_invite, published_invite_decline_reasons: [build_stubbed(:pool_invite_decline_reason, reason: 'location_not_convenient')])

        component = described_class.new(invite:)

        expect(component.change_preferences_text_component).to be_a(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::ChangeLocationPreferencesComponent)
      end
    end
  end

  describe '#candidate_interface_candidate_preferences_review_path' do
    context 'the candidate has no published preferences' do
      it 'returns the new_candidate_interface_pool_opt_in_path' do
        candidate = create(:candidate, published_preferences: [])
        invite = create(:pool_invite, candidate: candidate)

        component = described_class.new(invite:)
        render_inline(component) # needed to access the helper methods

        expect(component.candidate_interface_candidate_preferences_review_path).to eq(new_candidate_interface_pool_opt_in_path)
      end
    end

    context 'the candidate has published preference with opt-out' do
      it 'edit_candidate_interface_pool_opt_in_path(current_candidate.published_preferences.last)' do
        preference = build(:candidate_preference, :opt_out)
        candidate = create(:candidate, published_preferences: [preference])
        invite = create(:pool_invite, candidate: candidate)

        component = described_class.new(invite:)
        render_inline(component) # needed to access the helper methods

        expect(component.candidate_interface_candidate_preferences_review_path).to eq(edit_candidate_interface_pool_opt_in_path(preference))
      end
    end

    context 'the candidate has published preferences opt-in' do
      it 'candidate_interface_draft_preference_publish_preferences_path(current_candidate.published_preferences.last)' do
        preference = build(:candidate_preference, :opt_in)
        candidate = create(:candidate, published_preferences: [preference])
        invite = create(:pool_invite, candidate: candidate)

        component = described_class.new(invite:)
        render_inline(component) # needed to access the helper methods

        expect(component.candidate_interface_candidate_preferences_review_path).to eq(candidate_interface_draft_preference_publish_preferences_path(preference))
      end
    end
  end
end
