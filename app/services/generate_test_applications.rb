class GenerateTestApplications
  def generate
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    Reference.delete_all
    ApplicationChoice.delete_all
    ApplicationForm.delete_all

    100.times do |i|
      create_an_application(i)
    end
  end

private

  def create_an_application(application_index)
    first_name = Faker::Name.unique.first_name
    last_name = Faker::Name.unique.last_name
    candidate = FactoryBot.create(
      :candidate,
      email_address: "#{first_name.downcase}.#{last_name.downcase}@example.com",
    )

    Audited.audit_class.as_user(candidate) do
      application_form = FactoryBot.create(
        :completed_application_form,
        application_choices_count: 0,
        submitted_at: nil,
        candidate: candidate,
        first_name: first_name,
        last_name: last_name,
      )

      [1, 2, 3].sample.times do
        FactoryBot.create(
          :application_choice,
          status: 'unsubmitted',
          course_option: CourseOption.all.sample,
          application_form: application_form,
          personal_statement: Faker::Lorem.paragraph(sentence_count: 5),
        )
      end

      return if application_index > 90

      # The application is submitted by the candidate
      SubmitApplication.new(application_form).call

      return if application_index > 80

      # References come in
      application_form.references.each do |reference|
        ReceiveReference.new(
          application_form: application_form,
          referee_email: reference.email_address,
          feedback: 'You are awesome',
        ).save
      end

      return if application_index > 70

      application_form.application_choices.each do |application_choice|
        # This is only supposed to happen after 7 days, but SendApplicationToProvider
        # doesn't check the `edit_by` date of the ApplicationChoice
        SendApplicationToProvider.new(application_choice: application_choice).call
      end

      return if application_index > 60

      # Now the providers need to make a decision

      # First one gets an offer
      MakeAnOffer.new(application_choice: application_form.application_choices[0], offer_conditions: []).save

      return if application_index > 50

      if (second = application_form.application_choices[1])
        RejectApplication.new(application_choice: second, rejection_reason: 'Some').save
      end

      return if application_index > 40

      if (third = application_form.application_choices[2])
        RejectApplication.new(application_choice: third, rejection_reason: 'Some').save
      end

      # TODO: accept/decline/withdraw
    end
  end
end
