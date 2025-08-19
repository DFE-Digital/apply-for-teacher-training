class ProviderInterface::FindCandidates::InvitedCandidatesTableComponent < ViewComponent::Base
  def initialize(candidate_invites)
    @candidate_invites = candidate_invites&.group_by(&:candidate_id)
  end

  def candidate_link(candidate_id)
    invites = @candidate_invites[candidate_id]
    first_invite = invites.first
    if visible_application_for_invite?(invites)
      first_invite.application_form.full_name
    elsif candidate_not_in_pool?(candidate_id)
      govuk_link_to(
        first_invite.application_form.redacted_full_name,
        provider_interface_candidate_pool_invite_path(first_invite.id),
      )
    else
      govuk_link_to(
        first_invite.application_form.redacted_full_name,
        provider_interface_candidate_pool_candidate_path(candidate_id, return_to: 'invited'),
      )
    end
  end

  def status(invite)
    if invite.declined?
      govuk_tag(text: t('.declined'), colour: 'orange')
    elsif invite.matching_application_choice.nil?
      govuk_tag(text: t('.invited'), colour: 'yellow')
    else
      govuk_link_to(
        t('.application_received'),
        provider_interface_application_choice_path(application_choice_id: invite.matching_choice_id),
      )
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
    invites.any? { |invite| invite.matching_choice_id.present? }
  end
end
