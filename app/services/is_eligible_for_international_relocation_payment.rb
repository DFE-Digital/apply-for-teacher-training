class IsEligibleForInternationalRelocationPayment
  delegate :application_form, to: :application_choice

  ELIGIBLE_SUBJECTS = %i[physics].freeze

  def initialize(application_choice)
    @application_choice = application_choice
  end

  def call
    international? && eligible_subject? && right_to_work_or_study?
  end

private

  attr_reader :application_choice

  def right_to_work_or_study?
    application_form.right_to_work_or_study_yes? ||
      application_form.right_to_work_or_study_decide_later?
  end

  def international?
    application_form.address_type == 'international' &&
      application_form.international_applicant?
  end

  def eligible_subject?
    subject_codes.any? do |code|
      subject_mapping = MinisterialReport::SUBJECT_CODE_MAPPINGS[code]
      ELIGIBLE_SUBJECTS.include?(subject_mapping)
    end
  end

  def subject_codes
    application_choice.course_option.course.subject_codes
  end
end
