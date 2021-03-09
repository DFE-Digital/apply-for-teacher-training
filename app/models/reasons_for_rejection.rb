class ReasonsForRejection
  include ActiveModel::Model

  INITIAL_TOP_LEVEL_QUESTIONS = %i[
    candidate_behaviour_y_n
    quality_of_application_y_n
    qualifications_y_n
    performance_at_interview_y_n
    course_full_y_n
    offered_on_another_course_y_n
    honesty_and_professionalism_y_n
    safeguarding_y_n
  ].freeze

  TOP_LEVEL_REASONS_TO_I18N_KEYS = {
    candidate_behaviour_y_n: :candidate_behaviour_what_did_the_candidate_do,
    quality_of_application_y_n: :quality_of_application,
    qualifications_y_n: :qualifications_which_qualifications,
    honesty_and_professionalism_y_n: :honesty_and_professionalism,
    safeguarding_y_n: :safeguarding_issues,
    course_full_y_n: :full_course,
    offered_on_another_course_y_n: :offered_on_another_course,
    performance_at_interview_y_n: :interview_performance,
    interested_in_future_applications_y_n: :interested_in_future_applications,
    other_advice_or_feedback_y_n: :additional_advice,
  }.with_indifferent_access.freeze

  ALL_QUESTIONS = {
    candidate_behaviour_y_n: {
      candidate_behaviour_what_did_the_candidate_do: {
        other: %i[candidate_behaviour_other candidate_behaviour_what_to_improve],
      },
    },
    quality_of_application_y_n: {
      quality_of_application_which_parts_needed_improvement: {
        personal_statement: :quality_of_application_personal_statement_what_to_improve,
        subject_knowledge: :quality_of_application_subject_knowledge_what_to_improve,
        other: %i[quality_of_application_other_details quality_of_application_other_what_to_improve],
      },
    },
    qualifications_y_n: {
      qualifications_which_qualifications: {
        other: :qualifications_other_details,
      },
    },
    performance_at_interview_y_n: { performance_at_interview_what_to_improve: nil },
    offered_on_another_course_y_n: { offered_on_another_course_details: nil },
    honesty_and_professionalism_y_n: {
      honesty_and_professionalism_concerns: {
        information_false_or_inaccurate: :honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
        plagiarism: :honesty_and_professionalism_concerns_plagiarism_details,
        references: :honesty_and_professionalism_concerns_references_details,
        other: :honesty_and_professionalism_concerns_other_details,
      },
    },
    safeguarding_y_n: {
      safeguarding_concerns: {
        candidate_disclosed_information: :safeguarding_concerns_candidate_disclosed_information_details,
        vetting_disclosed_information: :safeguarding_concerns_vetting_disclosed_information_details,
        other: :safeguarding_concerns_other_details,
      },
    },
    other_advice_or_feedback_y_n: { other_advice_or_feedback_details: nil },
  }.freeze
  INITIAL_QUESTIONS = ALL_QUESTIONS.select { |key| INITIAL_TOP_LEVEL_QUESTIONS.include?(key) }.freeze

  attr_accessor :candidate_behaviour_y_n
  attr_writer :candidate_behaviour_what_did_the_candidate_do
  attr_accessor :candidate_behaviour_what_to_improve
  attr_accessor :candidate_behaviour_other

  def candidate_behaviour_what_did_the_candidate_do
    @candidate_behaviour_what_did_the_candidate_do || []
  end

  attr_accessor :quality_of_application_y_n
  attr_writer :quality_of_application_which_parts_needed_improvement
  attr_accessor :quality_of_application_personal_statement_what_to_improve
  attr_accessor :quality_of_application_subject_knowledge_what_to_improve
  attr_accessor :quality_of_application_other_details
  attr_accessor :quality_of_application_other_what_to_improve

  def quality_of_application_which_parts_needed_improvement
    @quality_of_application_which_parts_needed_improvement || []
  end

  attr_accessor :qualifications_y_n
  attr_writer :qualifications_which_qualifications
  attr_accessor :qualifications_other_details

  def qualifications_which_qualifications
    @qualifications_which_qualifications || []
  end

  attr_accessor :performance_at_interview_y_n
  attr_accessor :performance_at_interview_what_to_improve

  attr_accessor :course_full_y_n

  attr_accessor :offered_on_another_course_y_n
  attr_accessor :offered_on_another_course_details

  attr_accessor :honesty_and_professionalism_y_n
  attr_writer :honesty_and_professionalism_concerns
  attr_accessor :honesty_and_professionalism_concerns_information_false_or_inaccurate_details
  attr_accessor :honesty_and_professionalism_concerns_plagiarism_details
  attr_accessor :honesty_and_professionalism_concerns_references_details
  attr_accessor :honesty_and_professionalism_concerns_other_details

  def honesty_and_professionalism_concerns
    @honesty_and_professionalism_concerns || []
  end

  attr_accessor :safeguarding_y_n
  attr_writer :safeguarding_concerns
  attr_accessor :safeguarding_concerns_candidate_disclosed_information_details
  attr_accessor :safeguarding_concerns_vetting_disclosed_information_details
  attr_accessor :safeguarding_concerns_other_details

  def safeguarding_concerns
    @safeguarding_concerns || []
  end

  attr_accessor :other_advice_or_feedback_y_n
  attr_accessor :other_advice_or_feedback_details

  attr_accessor :interested_in_future_applications_y_n

  attr_accessor :why_are_you_rejecting_this_application

  def to_prose
    safeguarding_y_n.to_s
  end
end
