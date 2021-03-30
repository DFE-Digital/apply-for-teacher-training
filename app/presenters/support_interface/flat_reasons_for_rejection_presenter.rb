module SupportInterface
  class FlatReasonsForRejectionPresenter
    def self.build_from_structured_rejection_reasons(reasons_for_rejection)
      {
        title_for_top_level_reason('candidate_behaviour_y_n') => y_n_to_boolean(reasons_for_rejection.candidate_behaviour_y_n),
        label_for_subreason('candidate_behaviour_y_n', 'didnt_reply_to_interview_offer') => subreason_exists?(reasons_for_rejection.candidate_behaviour_what_did_the_candidate_do, 'didnt_reply_to_interview_offer'),
        label_for_subreason('candidate_behaviour_y_n', 'didnt_attend_interview') => subreason_exists?(reasons_for_rejection.candidate_behaviour_what_did_the_candidate_do, 'didnt_attend_interview'),
        label_for_subreason_detail('candidate_behaviour_y_n', 'other_details') => reasons_for_rejection.candidate_behaviour_other,
        label_for_subreason_detail('candidate_behaviour_y_n', 'what_to_improve_details') => reasons_for_rejection.candidate_behaviour_what_to_improve,
        title_for_top_level_reason('quality_of_application_y_n') => y_n_to_boolean(reasons_for_rejection.quality_of_application_y_n),
        label_for_subreason('quality_of_application_y_n', 'personal_statement') => subreason_exists?(reasons_for_rejection.quality_of_application_which_parts_needed_improvement, 'personal_statement'),
        label_for_subreason_detail('quality_of_application_y_n', 'personal_statement_what_to_improve_details') => reasons_for_rejection.quality_of_application_personal_statement_what_to_improve,
        label_for_subreason('quality_of_application_y_n', 'subject_knowledge') => subreason_exists?(reasons_for_rejection.quality_of_application_which_parts_needed_improvement, 'subject_knowledge'),
        label_for_subreason_detail('quality_of_application_y_n', 'subject_knowledge_what_to_improve_details') => reasons_for_rejection.quality_of_application_subject_knowledge_what_to_improve,
        label_for_subreason_detail('quality_of_application_y_n', 'other_what_to_improve_details') => reasons_for_rejection.quality_of_application_other_what_to_improve,
        label_for_subreason_detail('quality_of_application_y_n', 'other_details') => reasons_for_rejection.quality_of_application_other_details,
        title_for_top_level_reason('qualifications_y_n') => y_n_to_boolean(reasons_for_rejection.qualifications_y_n),
        label_for_subreason('qualifications_y_n', 'no_maths_gcse') => subreason_exists?(reasons_for_rejection.qualifications_which_qualifications, 'no_maths_gcse'),
        label_for_subreason('qualifications_y_n', 'no_english_gcse') => subreason_exists?(reasons_for_rejection.qualifications_which_qualifications, 'no_english_gcse'),
        label_for_subreason('qualifications_y_n', 'no_science_gcse') => subreason_exists?(reasons_for_rejection.qualifications_which_qualifications, 'no_science_gcse'),
        label_for_subreason('qualifications_y_n', 'no_degree') => subreason_exists?(reasons_for_rejection.qualifications_which_qualifications, 'no_degree'),
        label_for_subreason_detail('qualifications_y_n', 'other_details') => reasons_for_rejection.qualifications_other_details,
        title_for_top_level_reason('performance_at_interview_y_n') => y_n_to_boolean(reasons_for_rejection.performance_at_interview_y_n),
        label_for_subreason_detail('performance_at_interview_y_n', 'what_to_improve_details') => reasons_for_rejection.performance_at_interview_what_to_improve,
        title_for_top_level_reason('course_full_y_n') => y_n_to_boolean(reasons_for_rejection.course_full_y_n),
        title_for_top_level_reason('offered_on_another_course_y_n') => y_n_to_boolean(reasons_for_rejection.offered_on_another_course_y_n),
        label_for_subreason_detail('offered_on_another_course_y_n', 'other_details') => reasons_for_rejection.offered_on_another_course_details,
        title_for_top_level_reason('honesty_and_professionalism_y_n') => y_n_to_boolean(reasons_for_rejection.honesty_and_professionalism_y_n),
        label_for_subreason('honesty_and_professionalism_y_n', 'information_false_or_inaccurate') => subreason_exists?(reasons_for_rejection.honesty_and_professionalism_concerns, 'information_false_or_inaccurate'),
        label_for_subreason_detail('honesty_and_professionalism_y_n', 'information_false_or_inaccurate_details') => reasons_for_rejection.honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
        label_for_subreason('honesty_and_professionalism_y_n', 'plagiarism') => subreason_exists?(reasons_for_rejection.honesty_and_professionalism_concerns, 'plagiarism'),
        label_for_subreason_detail('honesty_and_professionalism_y_n', 'plagiarism_details') => reasons_for_rejection.honesty_and_professionalism_concerns_plagiarism_details,
        label_for_subreason('honesty_and_professionalism_y_n', 'references') => subreason_exists?(reasons_for_rejection.honesty_and_professionalism_concerns, 'references'),
        label_for_subreason_detail('honesty_and_professionalism_y_n', 'references_details') => reasons_for_rejection.honesty_and_professionalism_concerns_references_details,
        label_for_subreason_detail('honesty_and_professionalism_y_n', 'other_details') => reasons_for_rejection.honesty_and_professionalism_concerns_other_details,
        title_for_top_level_reason('safeguarding_y_n') => y_n_to_boolean(reasons_for_rejection.safeguarding_y_n),
        label_for_subreason('safeguarding_y_n', 'candidate_disclosed_information') => subreason_exists?(reasons_for_rejection.safeguarding_concerns, 'candidate_disclosed_information'),
        label_for_subreason_detail('safeguarding_y_n', 'candidate_disclosed_information_details') => reasons_for_rejection.safeguarding_concerns_candidate_disclosed_information_details,
        label_for_subreason('safeguarding_y_n', 'vetting_disclosed_information') => subreason_exists?(reasons_for_rejection.safeguarding_concerns, 'vetting_disclosed_information'),
        label_for_subreason_detail('safeguarding_y_n', 'vetting_disclosed_information_details') => reasons_for_rejection.safeguarding_concerns_vetting_disclosed_information_details,
        label_for_subreason_detail('safeguarding_y_n', 'other_details') => reasons_for_rejection.safeguarding_concerns_other_details,
        title_for_top_level_reason('other_advice_or_feedback_y_n') => y_n_to_boolean(reasons_for_rejection.other_advice_or_feedback_y_n),
        title_for_top_level_reason('interested_in_future_applications_y_n') => y_n_to_boolean(reasons_for_rejection.interested_in_future_applications_y_n),
        why_are_you_rejecting_this_application_details: reasons_for_rejection.why_are_you_rejecting_this_application,
      }
    end

    def self.build_top_level_reasons(structured_rejection_reasons)
      return nil if structured_rejection_reasons.blank?

      structured_rejection_reasons.select { |reason, value| ReasonsForRejection::INITIAL_TOP_LEVEL_QUESTIONS.include?(reason.to_sym) && value == 'Yes' }
          .keys
          .map { |reason| humanized_title_for_top_level_reason(reason) }
          .join(', ')
    end

    def self.y_n_to_boolean(string)
      string == 'Yes'
    end

    def self.subreason_exists?(reason, subreason)
      reason.include?(subreason)
    end

    def self.humanized_title_for_top_level_reason(reason)
      I18n.t("reasons_for_rejection.#{ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[reason]}.title")
    end

    def self.title_for_top_level_reason(reason)
      I18n.t("reasons_for_rejection.#{ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[reason]}.title").parameterize.underscore.to_sym
    end

    def self.label_for_subreason(reason, subreason)
      I18n.t("reasons_for_rejection.#{ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[reason]}.#{subreason}").gsub('’', "'").parameterize.underscore.to_sym
    end

    singleton_class.send(:alias_method, :label_for_subreason_detail, :label_for_subreason)
  end
end
