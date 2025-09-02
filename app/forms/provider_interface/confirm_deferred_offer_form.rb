class ProviderInterface::ConfirmDeferredOfferForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :course_id
  attribute :location_id
  attribute :study_mode
  attribute :conditions_status

  attribute :conditions, readonly: true
  attribute :application_choice, readonly: true
  attribute :offer_conditions_status, readonly: true

  validates :course_id, :location_id, :study_mode, :conditions_status, presence: true
  validates_inclusion_of :conditions_status, in: %w[met pending]

  validate :course_option_available

  def save
    return false unless valid?

    true
  end

  def course
    Course.find_by(id: course_id)
  end

  def location
    Site.find_by(id: location_id)
  end

  def course_option_in_new_cycle? = course_option_in_new_cycle.present?

  def conditions_met? = conditions_status == 'met'

  def confirm_offer(current_provider_user)
    ConfirmDeferredOffer.new(actor: current_provider_user,
                             application_choice:,
                             course_option: course_option_in_new_cycle,
                             conditions_met: conditions_met?).save
  end



private

  def course_option_in_new_cycle
    @course_option_in_new_cycle ||= application_choice.current_course_option&.in_next_cycle
  end

  def course_option_available
    unless course_option_in_new_cycle?
      errors.add(:course_option_in_new_cycle, "No matching course option in #{RecruitmentCycleTimetable.current_year}")
    end
  end
end
