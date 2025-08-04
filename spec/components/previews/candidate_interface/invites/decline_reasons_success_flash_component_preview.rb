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
end
