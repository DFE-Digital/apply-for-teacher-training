module SupportInterface
  class StructuredReasonsForRejectionExport
    def data_for_export
      data_for_export = application_choices.order(:id).map do |application_choice|
        structured_reasons_for_rejection = FlatReasonsForRejectionPresenter.build_from_structured_rejection_reasons(application_choice.structured_rejection_reasons)

        output = {
          'Candidate ID' => application_choice.application_form_id,
          'Application ID' => application_choice.id,
          'Candidate behaviour' => structured_reasons_for_rejection.candidate_behaviour,
          "Candidate behaviour - Didn't reply to our interview offer" => structured_reasons_for_rejection.didnt_reply_to_interview_offer,
          "Candidate behaviour - Didn't attend an interview" => structured_reasons_for_rejection.didnt_attend_interview,
          'Candidate behaviour - Other detail' => structured_reasons_for_rejection.candidate_behaviour_other_details,
          'Quality of application (y/n)' => structured_reasons_for_rejection.quality_of_application,
          'Quality of personal statement' => structured_reasons_for_rejection.personal_statement,
          'Quality of personal statement details' => structured_reasons_for_rejection.quality_of_application_personal_statement_what_to_improve,
          'Quality of subject knowledge' => structured_reasons_for_rejection.subject_knowledge,
          'Quality of subject knowledge details' => structured_reasons_for_rejection.quality_of_application_subject_knowledge_what_to_improve_details,
          'Quality of application other' => structured_reasons_for_rejection.quality_of_application_other_details,
          'Qualifications (y/n)' => structured_reasons_for_rejection.qualifications,
          'No Maths GCSE grade 4 (C) or above, or valid equivalent' => structured_reasons_for_rejection.no_maths_gcse,
          'No English GCSE grade 4 (C) or above, or valid equivalent' => structured_reasons_for_rejection.no_english_gcse,
          'No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants)' => structured_reasons_for_rejection.no_science_gcse,
          'No degree' => structured_reasons_for_rejection.no_degree,
          'Qualifications other' => structured_reasons_for_rejection.qualifications_other_details,
          'Performance at interview' => structured_reasons_for_rejection.performance_at_interview,
          'Performance at interview - What to improve' => structured_reasons_for_rejection.performance_at_interview_what_to_improve_details,
          'Course was full' => structured_reasons_for_rejection.course_full,
          'Offered another course' => structured_reasons_for_rejection.offered_on_another_course,
          'Concerns about honesty and professionalism' => structured_reasons_for_rejection.honesty_and_professionalism,
          'Honesty and professionalism - False or inaccurate information' => structured_reasons_for_rejection.information_false_or_inaccurate,
          'Honesty and professionalism - Information given on application form false or inaccurate' => structured_reasons_for_rejection.honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
          'Honesty and professionalism - Plagiarism' => structured_reasons_for_rejection.plagiarism,
          'Honesty and professionalism - Evidence of plagiarism in personal statement or elsewhere' => structured_reasons_for_rejection.honesty_and_professionalism_concerns_plagiarism_details,
          'Honesty and professionalism - References' => structured_reasons_for_rejection.references,
          'Honesty and professionalism - References didn’t support application' => structured_reasons_for_rejection.honesty_and_professionalism_concerns_references_details,
          'Honesty and professionalism - Other Concerns about honesty and professionalism' => structured_reasons_for_rejection.honesty_and_professionalism_concerns_other_details,
          'Safeguarding' => structured_reasons_for_rejection.safeguarding,
          'Information disclosed by candidate makes them unsuitable to work with children' => structured_reasons_for_rejection.candidate_disclosed_information,
          'Information disclosed by candidate makes them unsuitable to work with children - detail' => structured_reasons_for_rejection.safeguarding_concerns_candidate_disclosed_information_details,
          'Information revealed by our vetting process makes the candidate unsuitable to work with children' => structured_reasons_for_rejection.vetting_disclosed_information,
          'Information revealed by our vetting process makes the candidate unsuitable to work with children - detail' => structured_reasons_for_rejection.safeguarding_concerns_vetting_disclosed_information_details,
          'Safeguarding other' => structured_reasons_for_rejection.safeguarding_concerns_other_details,
        }

        output
      end

      data_for_export
    end

  private

    def application_choices
      ApplicationChoice.where.not(structured_rejection_reasons: nil)
    end
  end
end
