class DeclineOffer
  def initialize(application_choice:)
    @application_choice = application_choice
    @application_choices = application_choice.application_form.application_choices
  end

  def save!
    ApplicationStateChange.new(@application_choice).decline!
    @application_choice.update!(declined_at: Time.zone.now)
    StateChangeNotifier.call(:offer_declined, application_choice: @application_choice)

    if all_course_choices_unsuccessful && FeatureFlag.active?('apply_again')
      CandidateMailer.decline_last_application_choice(@application_choice).deliver_later
    end

    @application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.declined(provider_user, @application_choice).deliver_later
    end
  end

private

  def all_course_choices_unsuccessful
    @application_choices.size == @application_choices.select { |application_choice|
                                   application_choice.rejected? ||
                                     application_choice.withdrawn? ||
                                     application_choice.declined?
                                 } .size
  end
end
