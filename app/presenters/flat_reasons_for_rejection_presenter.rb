class FlatReasonsForRejectionPresenter
  def self.build_from_structured_rejection_reasons(reasons_for_rejection)
    {
      title_for_top_level_reason('candidate_behaviour_y_n') => y_n_to_boolean(reasons_for_rejection.candidate_behaviour_y_n),
      'didnt_reply_to_interview_offer' => subreason_exists?(reasons_for_rejection.candidate_behaviour_what_did_the_candidate_do, 'didnt_reply_to_interview_offer'),
      'didnt_attend_interview' => subreason_exists?(reasons_for_rejection.candidate_behaviour_what_did_the_candidate_do, 'didnt_attend_interview'),
      'candidate_behaviour_other_details' => reasons_for_rejection.candidate_behaviour_other,
      'candidate_behaviour_what_to_improve_details' => reasons_for_rejection.candidate_behaviour_what_to_improve,
      title_for_top_level_reason('quality_of_application_y_n') => y_n_to_boolean(reasons_for_rejection.quality_of_application_y_n),
      'personal_statement' => subreason_exists?(reasons_for_rejection.quality_of_application_which_parts_needed_improvement, 'personal_statement'),
      'quality_of_application_personal_statement_what_to_improve' => reasons_for_rejection.quality_of_application_personal_statement_what_to_improve,
      'subject_knowledge' => subreason_exists?(reasons_for_rejection.quality_of_application_which_parts_needed_improvement, 'subject_knowledge'),
      'quality_of_application_subject_knowledge_what_to_improve_details' => reasons_for_rejection.quality_of_application_subject_knowledge_what_to_improve,
      'quality_of_application_other_what_to_improve_details' => reasons_for_rejection.quality_of_application_other_what_to_improve,
      'quality_of_application_other_details' => reasons_for_rejection.quality_of_application_other_details,
      title_for_top_level_reason('qualifications_y_n') => y_n_to_boolean(reasons_for_rejection.qualifications_y_n),
      'no_maths_gcse' => subreason_exists?(reasons_for_rejection.qualifications_which_qualifications, 'no_maths_gcse'),
      'no_english_gcse' => subreason_exists?(reasons_for_rejection.qualifications_which_qualifications, 'no_english_gcse'),
      'no_science_gcse' => subreason_exists?(reasons_for_rejection.qualifications_which_qualifications, 'no_science_gcse'),
      'no_degree' => subreason_exists?(reasons_for_rejection.qualifications_which_qualifications, 'no_degree'),
      'qualifications_other_details' => reasons_for_rejection.qualifications_other_details,
      title_for_top_level_reason('performance_at_interview_y_n') => y_n_to_boolean(reasons_for_rejection.performance_at_interview_y_n),
      'performance_at_interview_what_to_improve_details' => reasons_for_rejection.performance_at_interview_what_to_improve,
      title_for_top_level_reason('course_full_y_n') => y_n_to_boolean(reasons_for_rejection.course_full_y_n),
      title_for_top_level_reason('offered_on_another_course_y_n') => y_n_to_boolean(reasons_for_rejection.offered_on_another_course_y_n),
      title_for_top_level_reason('honesty_and_professionalism_y_n') => y_n_to_boolean(reasons_for_rejection.honesty_and_professionalism_y_n),
      'information_false_or_inaccurate' => subreason_exists?(reasons_for_rejection.honesty_and_professionalism_concerns, 'information_false_or_inaccurate'),
      'honesty_and_professionalism_concerns_information_false_or_inaccurate_details' => reasons_for_rejection.honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
      'plagiarism' => subreason_exists?(reasons_for_rejection.honesty_and_professionalism_concerns, 'plagiarism'),
      'honesty_and_professionalism_concerns_plagiarism_details' => reasons_for_rejection.honesty_and_professionalism_concerns_plagiarism_details,
      'references' => subreason_exists?(reasons_for_rejection.honesty_and_professionalism_concerns, 'references'),
      'honesty_and_professionalism_concerns_references_details' => reasons_for_rejection.honesty_and_professionalism_concerns_references_details,
      'honesty_and_professionalism_concerns_other_details' => reasons_for_rejection.honesty_and_professionalism_concerns_other_details,
      title_for_top_level_reason('safeguarding_y_n') => y_n_to_boolean(reasons_for_rejection.safeguarding_y_n),
      'candidate_disclosed_information' => subreason_exists?(reasons_for_rejection.safeguarding_concerns, 'candidate_disclosed_information'),
      'safeguarding_concerns_candidate_disclosed_information_details' => reasons_for_rejection.safeguarding_concerns_candidate_disclosed_information_details,
      'vetting_disclosed_information' => subreason_exists?(reasons_for_rejection.safeguarding_concerns, 'vetting_disclosed_information'),
      'safeguarding_concerns_vetting_disclosed_information_details' => reasons_for_rejection.safeguarding_concerns_vetting_disclosed_information_details,
      'safeguarding_concerns_other_details' => reasons_for_rejection.safeguarding_concerns_other_details,
      title_for_top_level_reason('other_advice_or_feedback_y_n') => y_n_to_boolean(reasons_for_rejection.other_advice_or_feedback_y_n),
      title_for_top_level_reason('interested_in_future_applications_y_n') => y_n_to_boolean(reasons_for_rejection.interested_in_future_applications_y_n),
      'why_are_you_rejecting_this_application_details' => reasons_for_rejection.why_are_you_rejecting_this_application,
    }
  end

  def self.build_top_level_reasons(structured_rejection_reasons)
    return nil if structured_rejection_reasons.blank?

    structured_rejection_reasons.select { |reason, value| ReasonsForRejection::INITIAL_TOP_LEVEL_QUESTIONS.include?(reason.to_sym) && value == 'Yes' }
    .keys
    .map { |reason| title_for_top_level_reason(reason) }
    .join("\n")
  end

  def self.y_n_to_boolean(string)
    string == 'Yes'
  end

  def self.subreason_exists?(reason, subreason)
    reason.include?(subreason)
  end

  def self.title_for_top_level_reason(reason)
    I18n.t("reasons_for_rejection.#{ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[reason]}.title")
  end
end
