class ChangeOffer
  include ActiveModel::Validations

  attr_reader :application_choice, :course_option_id

  validates_each :course_option_id do |record, attr, value|
    record.errors.add(attr, :no_change) if value == record.application_choice.offered_option.id
  end

  def initialize(actor:, application_choice:, course_option_id:, offer_conditions: nil)
    @application_choice = application_choice
    @course_option_id = course_option_id
    @offer_conditions = offer_conditions
    @auth = ProviderAuthorisation.new(actor: actor)
  end

  def save
    @auth.assert_can_change_offer! application_choice: @application_choice, course_option_id: @course_option_id
    if valid?
      attributes = {
        offered_course_option_id: @course_option_id,
        offered_at: Time.zone.now,
      }
      attributes[:offer] = { 'conditions' => @offer_conditions } if @offer_conditions
      @application_choice.update! attributes

      SetDeclineByDefault.new(application_form: @application_choice.application_form).call
      CandidateMailer.changed_offer(@application_choice).deliver_later
      # TODO: StateChangeNotifier.call(:change_offer, application_choice: application_choice)
    end
  end
end
