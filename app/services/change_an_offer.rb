class ChangeAnOffer
  include ActiveModel::Validations
  include ImpersonationAuditHelper

  attr_reader :application_choice, :course_option

  validates :course_option, presence: true
  validate :validate_offer_is_not_identical
  validate :validate_course_option_is_open_on_apply

  def initialize(actor:, application_choice:, course_option:, offer_conditions: nil)
    @application_choice = application_choice
    @course_option = course_option
    @offer_conditions = offer_conditions
    @auth = ProviderAuthorisation.new(actor: actor)
  end

  def identical_to_existing_offer?
    course_option.present? && \
      course_option == application_choice.offered_option && \
      application_choice.offer['conditions'] == @offer_conditions
  end

  def save
    @auth.assert_can_make_decisions! application_choice: @application_choice, course_option_id: @course_option.id
    audit(@auth.actor) do
      if valid?
        now = Time.zone.now
        attributes = {
          offered_course_option: @course_option,
          offer_changed_at: now,
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
  end

private

  def validate_course_option_is_open_on_apply
    if course_option.present? && !course_option.course.open_on_apply
      errors.add(:course_option, :not_open_on_apply)
    end
  end

  def validate_offer_is_not_identical
    if identical_to_existing_offer?
      errors.add(:base, 'The new offer is identical to the current offer')
    end
  end
end
