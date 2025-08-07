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
end
