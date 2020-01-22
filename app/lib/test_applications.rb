module TestApplications
  def self.create_application(states)
    first_name = Faker::Name.unique.first_name
    last_name = Faker::Name.unique.last_name
    candidate = FactoryBot.create(
      :candidate,
      email_address: "#{first_name.downcase}.#{last_name.downcase}@example.com",
    )

    #rubocop:disable Metrics/BlockLength
    Audited.audit_class.as_user(candidate) do
      application_form = FactoryBot.create(
        :completed_application_form,
        application_choices_count: 0,
        work_experiences_count: 1,
        volunteering_experiences_count: 1,
        references_count: 2,
        with_gces: true,
        submitted_at: nil,
        candidate: candidate,
        first_name: first_name,
        last_name: last_name,
      )

      application_choices = FactoryBot.create_list(
        :application_choice,
        states.count,
        status: 'unsubmitted',
        course_option: CourseOption.all.sample,
        application_form: application_form,
        personal_statement: Faker::Lorem.paragraph(sentence_count: 5),
      )

      return if states.include? :unsubmitted

      SubmitApplication.new(application_form).call
      return if states.include? :awaiting_references

      application_form.application_references.each do |reference|
        ReceiveReference.new(
          reference: reference,
          feedback: 'You are awesome',
        ).save
      end
      return if states.include? :application_complete

      application_choices.map(&:reload)

      states.zip(application_choices).each do |state, application_choice|
        put_application_choice_in_state(application_choice, state)
      end
    end
    #rubocop:enable Metrics/BlockLength
  end

  def self.put_application_choice_in_state(choice, state)
    # This is only supposed to happen after 7 days, but SendApplicationToProvider
    # doesn't check the `edit_by` date of the ApplicationChoice
    SendApplicationToProvider.new(application_choice: choice).call
    choice.update(edit_by: Time.zone.now)
    return if state == :awaiting_provider_decision

    if state == :offer
      MakeAnOffer.new(application_choice: choice, offer_conditions: ['Complete DBS']).save
    elsif state == :rejected
      RejectApplication.new(application_choice: choice, rejection_reason: 'Some').save
    elsif state == :declined
      MakeAnOffer.new(application_choice: choice, offer_conditions: ['Complete DBS']).save
      DeclineOffer.new(application_choice: choice).save!
    elsif state == :accepted
      MakeAnOffer.new(application_choice: choice, offer_conditions: ['Complete DBS']).save
      AcceptOffer.new(application_choice: choice).save!
    elsif state == :recruited
      MakeAnOffer.new(application_choice: choice, offer_conditions: ['Complete DBS']).save
      AcceptOffer.new(application_choice: choice).save!
      ConfirmOfferConditions.new(application_choice: choice).save
    elsif state == :enrolled
      MakeAnOffer.new(application_choice: choice, offer_conditions: ['Complete DBS']).save
      AcceptOffer.new(application_choice: choice).save!
      ConfirmOfferConditions.new(application_choice: choice).save
      ConfirmEnrolment.new(application_choice: choice).save
    elsif state == :withdrawn
      WithdrawApplication.new(application_choice: choice).save!
    end
  end
end
