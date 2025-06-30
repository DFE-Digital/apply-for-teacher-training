module DataMigrations
  class BackfillApplicationFormOnPoolInvites
    TIMESTAMP = 20250630103024
    MANUAL_RUN = false

    def change
      # There are currently about 1500 invites, so this will take no time at all. Tested locally with 1300
      Pool::Invite.where(application_form: nil).includes(candidate: :application_forms).find_each do |invite|
        invite.update(application_form: invite.candidate.current_application)
      end
    end
  end
end
