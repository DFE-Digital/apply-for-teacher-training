# frozen_string_literal: true

class CandidateInterface::Invites::DeclineReasonsSuccessFlashComponentPreview < ViewComponent::Preview
  def default
    invite = FactoryBot.build_stubbed(:pool_invite)

    component = CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent.new(invite:)

    render(component)
  end

  def no_longer_interested
    invite = FactoryBot.build_stubbed(:pool_invite)

    component = CandidateInterface::Invites::DeclineReasonsSuccessFlash::NoLongerInterestedComponent.new(invite:)

    render(component)
  end

  def change_location_and_funding_preferences
    preference = FactoryBot.build_stubbed(:candidate_preference, pool_status: :opt_in, funding_type: 'salary')
    application_form = FactoryBot.build_stubbed(:application_form, published_preference: preference)
    invite = FactoryBot.build_stubbed(:pool_invite, application_form: application_form)

    component = CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeLocationAndFundingPreferencesComponent.new(invite:)

    render(component)
  end

  def change_funding_preferences
    application_form = FactoryBot.build_stubbed(:application_form, published_preference: FactoryBot.build_stubbed(:candidate_preference, pool_status: :opt_in, funding_type: 'salary'))
    invite = FactoryBot.build_stubbed(:pool_invite, application_form: application_form)

    component = CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeFundingPreferencesComponent.new(invite:)

    render(component)
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
