class FlatReasonsForRejectionExtractCopy
  include ActiveModel::Model

  attr_accessor :structured_rejection_reasons_hash, :candidate_behaviour, :didnt_reply_to_interview_offer, :didnt_attend_interview
  attr_accessor :candidate_behaviour_other_details, :candidate_behaviour_what_to_improve_details, :quality_of_application, :personal_statement
  attr_accessor :quality_of_application_personal_statement_what_to_improve, :subject_knowledge, :quality_of_application_subject_knowledge_what_to_improve_details
  attr_accessor :quality_of_application_other_what_to_improve_details, :quality_of_application_other_details, :qualifications, :no_maths_gcse
  attr_accessor :no_english_gcse, :no_science_gcse, :no_degree, :qualifications_other_details, :performance_at_interview
  attr_accessor :performance_at_interview_what_to_improve_details, :course_full, :offered_on_another_course, :honesty_and_professionalism
  attr_accessor :information_false_or_inaccurate, :honesty_and_professionalism_concerns_information_false_or_inaccurate_details
  attr_accessor :plagiarism, :honesty_and_professionalism_concerns_plagiarism_details, :references, :honesty_and_professionalism_concerns_references_details
  attr_accessor :honesty_and_professionalism_concerns_other_details, :safeguarding, :candidate_disclosed_information
  attr_accessor :safeguarding_concerns_candidate_disclosed_information_details, :vetting_disclosed_information, :safeguarding_concerns_vetting_disclosed_information_details
  attr_accessor :safeguarding_concerns_other_details, :other_advice_or_feedback, :interested_in_future_applications, :why_are_you_rejecting_this_application_details

  def self.build_from_hash(structured_rejection_reasons)
    new(
      candidate_behaviour: word_to_boolean(structured_rejection_reasons['candidate_behaviour_y_n']),
      didnt_reply_to_interview_offer: subreason_exists?(structured_rejection_reasons['candidate_behaviour_what_did_the_candidate_do'],'didnt_reply_to_interview_offer'),
      didnt_attend_interview: subreason_exists?(structured_rejection_reasons['candidate_behaviour_what_did_the_candidate_do'], 'didnt_attend_interview'),
      candidate_behaviour_other_details: structured_rejection_reasons['candidate_behaviour_other'],
      candidate_behaviour_what_to_improve_details: structured_rejection_reasons['candidate_behaviour_what_to_improve'],
      quality_of_application: word_to_boolean(structured_rejection_reasons['quality_of_application_y_n']),
      personal_statement: subreason_exists?(structured_rejection_reasons['quality_of_application_which_parts_needed_improvement'], 'personal_statement'),
      quality_of_application_personal_statement_what_to_improve: structured_rejection_reasons['quality_of_application_personal_statement_what_to_improve'],
      subject_knowledge: subreason_exists?(structured_rejection_reasons['quality_of_application_which_parts_needed_improvement'], 'subject_knowledge'),
      quality_of_application_subject_knowledge_what_to_improve_details: structured_rejection_reasons['quality_of_application_subject_knowledge_what_to_improve'],
      quality_of_application_other_what_to_improve_details: structured_rejection_reasons['quality_of_application_other_what_to_improve'],
      quality_of_application_other_details: structured_rejection_reasons['quality_of_application_other_details'],
      qualifications: word_to_boolean(structured_rejection_reasons['qualifications_y_n']),
      no_maths_gcse: subreason_exists?(structured_rejection_reasons['qualifications_which_qualifications'], 'no_maths_gcse'),
      no_english_gcse: subreason_exists?(structured_rejection_reasons['qualifications_which_qualifications'], 'no_english_gcse'),
      no_science_gcse: subreason_exists?(structured_rejection_reasons['qualifications_which_qualifications'], 'no_science_gcse'),
      no_degree: subreason_exists?(structured_rejection_reasons['qualifications_which_qualifications'], 'no_degree'),
      qualifications_other_details: structured_rejection_reasons['qualifications_other_details'],
      performance_at_interview: word_to_boolean(structured_rejection_reasons['performance_at_interview_y_n']),
      performance_at_interview_what_to_improve_details: structured_rejection_reasons['performance_at_interview_what_to_improve'],
      course_full: word_to_boolean(structured_rejection_reasons['course_full_y_n']),
      offered_on_another_course: word_to_boolean(structured_rejection_reasons['offered_on_another_course_y_n']),
      honesty_and_professionalism: word_to_boolean(structured_rejection_reasons['honesty_and_professionalism_y_n']),
      information_false_or_inaccurate: subreason_exists?(structured_rejection_reasons['honesty_and_professionalism_concerns'], 'information_false_or_inaccurate'),
      honesty_and_professionalism_concerns_information_false_or_inaccurate_details: structured_rejection_reasons['honesty_and_professionalism_concerns_information_false_or_inaccurate_details'],
      plagiarism: subreason_exists?(structured_rejection_reasons['honesty_and_professionalism_concerns'], 'plagiarism'),
      honesty_and_professionalism_concerns_plagiarism_details: structured_rejection_reasons['honesty_and_professionalism_concerns_plagiarism_details'],
      references: subreason_exists?(structured_rejection_reasons['honesty_and_professionalism_concerns'], 'references'),
      honesty_and_professionalism_concerns_references_details: structured_rejection_reasons['honesty_and_professionalism_concerns_references_details'],
      honesty_and_professionalism_concerns_other_details: structured_rejection_reasons['honesty_and_professionalism_concerns_other_details'],
      safeguarding: word_to_boolean(structured_rejection_reasons['safeguarding_y_n']),
      candidate_disclosed_information: subreason_exists?(structured_rejection_reasons['safeguarding_concerns'], 'candidate_disclosed_information'),
      safeguarding_concerns_candidate_disclosed_information_details: structured_rejection_reasons['safeguarding_concerns_candidate_disclosed_information_details'],
      vetting_disclosed_information: subreason_exists?(structured_rejection_reasons['safeguarding_concerns'], 'vetting_disclosed_information'),
      safeguarding_concerns_vetting_disclosed_information_details: structured_rejection_reasons['safeguarding_concerns_vetting_disclosed_information_details'],
      safeguarding_concerns_other_details: structured_rejection_reasons['safeguarding_concerns_other_details'],
      other_advice_or_feedback: word_to_boolean(structured_rejection_reasons['other_advice_or_feedback_y_n']),
      interested_in_future_applications: word_to_boolean(structured_rejection_reasons['interested_in_future_applications_y_n']),
      why_are_you_rejecting_this_application_details: structured_rejection_reasons['why_are_you_rejecting_this_application']
    )
  end

  def self.word_to_boolean(word)
    return false if word.nil?

    word == 'Yes'
  end

  def self.subreason_exists?(reason, subreason)
    return false if reason.nil?

    reason.include?(subreason)
  end

  # These three methods are copied from the application_choices_export.rb & equality_and_diversity_export.rb - will be refactored later
  def formatted
    return nil if @structured_rejection_reasons.blank?

    select_top_level_rejection_reasons(@structured_rejection_reasons)
    .keys
    .map { |reason| format_reason(reason) }
    .join("\n")
  end

  def select_top_level_rejection_reasons(structured_rejection_reasons)
    structured_rejection_reasons.select { |reason, value| value == 'Yes' && reason.include?('_y_n') }
  end

  def format_reason(reason)
    reason
    .delete_suffix('_y_n')
    .humanize
  end
end
