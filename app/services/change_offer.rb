class ChangeOffer
  include ActiveModel::Validations

  attr_reader :application_choice, :course_option

  validates :course_option, presence: true
  validate :validate_course_option_is_not_the_same_as_existing_course_option
  validate :validate_course_option_is_open_on_apply

  def initialize(actor:, application_choice:, course_option:, offer_conditions: nil)
    @application_choice = application_choice
    @course_option = course_option
    @offer_conditions = offer_conditions
    @auth = ProviderAuthorisation.new(actor: actor)
  end

  def save
    @auth.assert_can_make_decisions! application_choice: @application_choice, course_option_id: @course_option.id
    if valid?
      attributes = {
        offered_course_option: @course_option,
        offered_at: Time.zone.now,
      }
      attributes[:offer] = { 'conditions' => @offer_conditions } if @offer_conditions
      @application_choice.update! attributes

      SetDeclineByDefault.new(application_form: @application_choice.application_form).call
      CandidateMailer.changed_offer(@application_choice).deliver_later
      StateChangeNotifier.call(:change_an_offer, application_choice: @application_choice)

      true
    else
      false
    end
  end

private

  def validate_course_option_is_not_the_same_as_existing_course_option
    if course_option.present? && course_option == application_choice.offered_option
      errors.add(:course_option, :no_change)
    end
  end

  def validate_course_option_is_open_on_apply
    if course_option.present? && !course_option.course.open_on_apply
      errors.add(:course_option, :not_open_on_apply)
    end
  end
end
