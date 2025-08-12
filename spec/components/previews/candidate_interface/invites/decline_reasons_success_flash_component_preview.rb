# frozen_string_literal: true

class CandidateInterface::Invites::DeclineReasonsSuccessFlashComponentPreview < ViewComponent::Preview
  include ViewComponent::TestHelpers

  def default
    invite = FactoryBot.build_stubbed(:pool_invite)

    component_html = render_inline(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent.new(invite:)).to_s

    render(::FlashMessageComponent.new(flash: {
      success: [
        I18n.t('candidate_interface.decline_reasons.create.header',
               course: invite.course.name_and_code,
               provider: invite.provider_name),
        component_html,
      ],
    }))
  end

  def update_location_and_funding_preferences
    invite = FactoryBot.build_stubbed(:pool_invite)

    component_html = render_inline(CandidateInterface::Invites::DeclineReasonsSuccessFlash::UpdateLocationAndFundingPreferencesComponent.new(invite:)).to_s

    render(::FlashMessageComponent.new(flash: {
      success: [
        I18n.t('candidate_interface.decline_reasons.create.header',
               course: invite.course.name_and_code,
               provider: invite.provider_name),
        component_html,
      ],
    }))
  end

  def change_funding_preferences
    candidate = FactoryBot.build_stubbed(:candidate, published_preference: FactoryBot.build_stubbed(:candidate_preference, pool_status: :opt_in, funding_type: 'salary'))
    invite = FactoryBot.build_stubbed(:pool_invite, candidate: candidate)

    component_html = render_inline(CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeFundingPreferencesComponent.new(invite:)).to_s

    render(::FlashMessageComponent.new(flash: {
      success: [
        I18n.t('candidate_interface.decline_reasons.create.header',
               course: invite.course.name_and_code,
               provider: invite.provider_name),
        component_html,
      ],
    }))
  end

  def change_location_preferences
    invite = FactoryBot.build_stubbed(:pool_invite)

    component_html = render_inline(CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeLocationPreferencesComponent.new(invite:)).to_s

    render(::FlashMessageComponent.new(flash: {
      success: [
        I18n.t('candidate_interface.decline_reasons.create.header',
               course: invite.course.name_and_code,
               provider: invite.provider_name),
        component_html,
      ],
    }))
  end
end
