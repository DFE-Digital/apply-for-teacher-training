class ProviderInterface::FindCandidates::InvitedCandidatesTableComponent < ViewComponent::Base
  def initialize(candidate_invites)
    @candidate_invites = candidate_invites&.group_by(&:candidate_id)
  end

  def candidate_link(candidate_id)
    invites = @candidate_invites[candidate_id]
    if visible_application_for_invite?(invites)
      invites.first.application_form.full_name
    elsif candidate_not_in_pool?(candidate_id)
      invites.first.application_form.redacted_full_name
    else
      govuk_link_to(
        invites.first.application_form.redacted_full_name,
        provider_interface_candidate_pool_candidate_path(candidate_id, return_to: 'invited'),
      )
    end
  end

  def status(invite)
    matching_choice = invite.application_choice_with_course_match_visible_to_provider
    if matching_choice.present?
      govuk_link_to(
        t('.application_received'),
        provider_interface_application_choice_path(matching_choice),
      )
    else
      govuk_tag(text: t('.invited'), colour: 'yellow')
    end
  end

  def html_options(invites_count, invite_index)
    # Only show the border on the last invite for a candidate
    if invites_count > 1 && invite_index < invites_count - 1
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

  def visible_application_for_invite?(invites)
    invites.any? do |invite|
      invite.application_choice_with_course_match_visible_to_provider.present?
    end
  end
end
