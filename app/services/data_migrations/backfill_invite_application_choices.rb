module DataMigrations
  class BackfillInviteApplicationChoices
    TIMESTAMP = 20250717152335
    MANUAL_RUN = false

    def change
      invites = Pool::Invite.published
      .joins(application_form: :application_choices)
      .where(application_choice_id: nil)
      .where(application_choices: { status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER })
      .where(
        '(SELECT course_id FROM course_options WHERE id = application_choices.original_course_option_id) = pool_invites.course_id OR
        (SELECT course_id FROM course_options WHERE id = application_choices.current_course_option_id) = pool_invites.course_id OR
        (SELECT course_id FROM course_options WHERE id = application_choices.course_option_id) = pool_invites.course_id',
      )
      .select('DISTINCT ON (pool_invites.id) pool_invites.*, application_choices.id as choice_id')

      ActiveRecord::Base.transaction do
        invites.find_each do |invite|
          invite.update(
            application_choice_id: invite.choice_id,
            candidate_decision: 'applied',
          )
        end
      end
    end
  end
end
