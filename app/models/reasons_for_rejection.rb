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
    cannot_sponsor_visa_y_n
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
    cannot_sponsor_visa_y_n: :cannot_sponsor_visa,
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
    cannot_sponsor_visa_y_n: { cannot_sponsor_visa_details: nil },
    other_advice_or_feedback_y_n: { other_advice_or_feedback_details: nil },
  }.freeze
  INITIAL_QUESTIONS = ALL_QUESTIONS.select { |key| INITIAL_TOP_LEVEL_QUESTIONS.include?(key) }.freeze

  attr_writer :candidate_behaviour_what_did_the_candidate_do, :quality_of_application_which_parts_needed_improvement,
              :qualifications_which_qualifications, :honesty_and_professionalism_concerns, :safeguarding_concerns
  attr_accessor :candidate_behaviour_y_n, :candidate_behaviour_what_to_improve, :candidate_behaviour_other,
                :quality_of_application_y_n, :quality_of_application_personal_statement_what_to_improve,
                :quality_of_application_subject_knowledge_what_to_improve, :quality_of_application_other_details,
                :quality_of_application_other_what_to_improve,
                :qualifications_y_n, :qualifications_other_details,
                :performance_at_interview_y_n, :performance_at_interview_what_to_improve,
                :course_full_y_n,
                :offered_on_another_course_y_n, :offered_on_another_course_details,
                :honesty_and_professionalism_y_n, :honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
                :honesty_and_professionalism_concerns_plagiarism_details, :honesty_and_professionalism_concerns_references_details,
                :honesty_and_professionalism_concerns_other_details,
                :safeguarding_y_n, :safeguarding_concerns_candidate_disclosed_information_details,
                :safeguarding_concerns_vetting_disclosed_information_details, :safeguarding_concerns_other_details,
                :cannot_sponsor_visa_y_n, :cannot_sponsor_visa_details,
                :other_advice_or_feedback_y_n, :other_advice_or_feedback_details,
                :interested_in_future_applications_y_n, :why_are_you_rejecting_this_application

  def candidate_behaviour_what_did_the_candidate_do
    @candidate_behaviour_what_did_the_candidate_do || []
  end

  def quality_of_application_which_parts_needed_improvement
    @quality_of_application_which_parts_needed_improvement || []
  end

  def qualifications_which_qualifications
    @qualifications_which_qualifications || []
  end

  def honesty_and_professionalism_concerns
    @honesty_and_professionalism_concerns || []
  end

  def safeguarding_concerns
    @safeguarding_concerns || []
  end

  def to_prose
    safeguarding_y_n.to_s
  end
end
