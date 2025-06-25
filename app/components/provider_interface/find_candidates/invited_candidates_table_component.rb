class ProviderInterface::FindCandidates::InvitedCandidatesTableComponent < ViewComponent::Base
  def initialize(candidate_invites)
    @candidate_invites = candidate_invites&.group_by(&:candidate_id)
  end

  def candidate_link(candidate_id)
    name = candidate_name(candidate_id)

    if candidate_not_in_pool?(candidate_id) || visible_application_for_invite?(candidate_id)
      name
    else
      # Users can only view the pool profile if they are in the pool
      govuk_link_to(
        name,
        provider_interface_candidate_pool_candidate_path(candidate_id, return_to: 'invited'),
      )
    end
  end

  def visually_hidden_name(candidate_id)
    tag.span("#{candidate_name(candidate_id)} #{candidate_id}", class: 'govuk-visually-hidden')
  end

  def course_name(invite)
    invite.course.name_and_code
  end

  def status(invite)
    if invite.application_choice_with_course_match_visible_to_provider.present?
      govuk_link_to(
        t('.application_received'),
        provider_interface_application_choice_path(invite.application_choice_with_course_match_visible_to_provider),
      )
    else
      govuk_tag(text: 'Invited', colour: 'green')
    end
  end

  def html_options(invites_count, invite_index)
    # Only show the border on the last invite for a candidate
    if invites_count > 1 && invites_count != invite_index + 1
      { html_attributes: { class: 'find-a-candidate-invitations-table__cell--no-bottom-border' } }
    else
      {}
    end
  end

private

  def candidate_not_in_pool?(candidate_id)
    pool_candidates.find_by(candidate_id:).blank?
  end

  def pool_candidates
    @pool_candidates ||= Pool::Candidates.application_forms_for_provider
  end

  def visible_application_for_invite?(candidate_id)
    @candidate_invites[candidate_id].any? do |invite|
      invite.application_choice_with_course_match_visible_to_provider.present?
    end
  end

  def candidate_name(candidate_id)
    if visible_application_for_invite?(candidate_id)
      @candidate_invites[candidate_id].first.application_form.full_name
    else
      @candidate_invites[candidate_id].first.application_form.redacted_full_name
    end
  end
end
