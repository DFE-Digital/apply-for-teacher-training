class ChangeOffer
  include ActiveModel::Validations

  def initialize(actor:, application_choice:, course_option_id:)
    @application_choice = application_choice
    @course_option_id = course_option_id
    @auth = ProviderAuthorisation.new(actor: actor)
  end

  def save!
    @auth.assert_can_change_offer! application_choice: @application_choice, course_option_id: @course_option_id
    if @course_option_id != @application_choice.offered_option.id
      @application_choice.update!(offered_course_option_id: @course_option_id, offered_at: Time.zone.now)

      SetDeclineByDefault.new(application_form: @application_choice.application_form).call
      # TODO: SendChangeOfferEmailToCandidate.new(application_choice: @application_choice).call
      # TODO: StateChangeNotifier.call(:change_offer, application_choice: application_choice)
    end
  end
end
