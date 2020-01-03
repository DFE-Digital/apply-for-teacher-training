class MakeAnOffer
  attr_accessor :standard_conditions
  attr_accessor :further_conditions0, :further_conditions1, :further_conditions2, :further_conditions3

  include ActiveModel::Validations

  MAX_CONDITIONS_COUNT = 20
  MAX_CONDITION_LENGTH = 255

  validate :validate_course_data
  validate :validate_conditions_max_length
  validate :validate_further_conditions

  def initialize(
    application_choice:,
    offer_conditions: nil,
    standard_conditions: nil,
    further_conditions: {},
    course_data: nil
  )
    @application_choice = application_choice
    @offer_conditions = offer_conditions
    @standard_conditions = standard_conditions
    @course_data = course_data
    further_conditions.each { |key, value| self.send("#{key}=", value) }
  end

  def save
    return unless valid?

    ApplicationStateChange.new(application_choice).make_offer!
    application_choice.offered_course_option = offered_course_option
    application_choice.offer = { 'conditions' => offer_conditions }

    application_choice.offered_at = Time.zone.now
    application_choice.save!

    SetDeclineByDefault.new(application_form: application_choice.application_form).call
    StateChangeNotifier.call(:make_an_offer, application_choice: application_choice)
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end

  def offer_conditions
    @offer_conditions ||= [
      standard_conditions,
      further_conditions,
    ].flatten.reject(&:blank?)
  end

private

  attr_reader :application_choice

  def offered_course_option
    return nil if @course_data.nil?

    @course_option
  end

  def further_conditions
    [
      further_conditions0,
      further_conditions1,
      further_conditions2,
      further_conditions3,
    ]
  end

  def validate_course_data
    return if @course_data.nil?

    provider_code = @course_data[:provider_code]
    course_code = @course_data[:course_code]
    recruitment_cycle_year = @course_data[:recruitment_cycle_year]
    study_mode = @course_data[:study_mode]
    site_code = @course_data[:site_code]

    provider = Provider.find_by(code: provider_code)
    if provider.nil?
      errors.add(:offered_course, "provider #{provider_code} does not exist")
      return
    end

    course = provider.courses.find_by(
      code: course_code,
      recruitment_cycle_year: recruitment_cycle_year,
      study_mode: study_mode,
    )
    if course.nil?
      errors.add(:offered_course, "#{course_code} from recruitment cycle year #{recruitment_cycle_year} with study mode #{study_mode} does not exist or does not belong to provider #{provider_code}")
      return
    end

    site = provider.sites.find_by(code: site_code)
    if site.nil?
      errors.add(:offered_course, "site #{site_code} does not exist or does not belong to provider #{provider_code}")
      return
    end

    @course_option = CourseOption.find_by(course: course, site: site, study_mode: study_mode)
    if @course_option.nil?
      errors.add(:offered_course, 'does not exist')
      return
    end

    current_provider = @application_choice.course_option.course.provider
    providers_dont_match = current_provider != provider
    errors.add(:offered_course, "does not belong to provider #{current_provider.code}, it belongs to #{provider.code}") if providers_dont_match
  end

  def validate_further_conditions
    return if further_conditions.blank?

    further_conditions.each_with_index do |value, index|
      if value && value.length > MAX_CONDITION_LENGTH
        errors.add(
          "further_conditions#{index}",
          I18n.t(
            'activemodel.errors.models.support_interface/new_offer_form.attributes.further_conditions.too_long',
            name: I18n.t("activemodel.attributes.support_interface/new_offer.further_conditions#{index}"),
            limit: MAX_CONDITION_LENGTH,
          ),
        )
      end
    end
  end

  def validate_conditions_max_length
    return if offer_conditions.is_a?(Array) && offer_conditions.count <= MAX_CONDITIONS_COUNT

    errors.add(:offer_conditions, "has over #{MAX_CONDITIONS_COUNT} elements")
  end
end
