module CandidateInterface
  class Gcse::English::GradeController < Gcse::BaseController
    def edit
      @gcse_grade_form = english_gcse_grade_form
      @qualification_type = gcse_english_qualification.qualification_type

      render view_path
    end

    def update
      @qualification_type = gcse_english_qualification.qualification_type
      @gcse_grade_form = english_gcse_grade_form.assign_values(english_details_params)

      if @gcse_grade_form.save
        redirect_to next_gcse_path
      else
        track_validation_error(@gcse_grade_form)
        render view_path
      end
    end

  private

    def english_details_params
      strip_whitespace params
        .require(:candidate_interface_english_gcse_grade_form)
        .permit([
          :english_single_award,
          :grade_english_single,
          :english_double_award,
          :grade_english_double,
          :english_language,
          :grade_english_language,
          :english_literature,
          :grade_english_literature,
          :english_studies_single_award,
          :grade_english_studies_single,
          :english_studies_double_award,
          :grade_english_studies_double,
          :other_english_gcse,
          :other_english_gcse_name,
          :grade_other_english_gcse,
          :grade,
          :other_grade,
          english_gcses: [],
        ])
    end

    def next_gcse_path
      if current_qualification.failed_required_gcse?
        candidate_interface_gcse_details_edit_grade_explanation_path(subject: @subject)
      elsif english_gcse_grade_form.award_year.nil?
        candidate_interface_gcse_details_edit_year_path(subject: @subject)
      else
        candidate_interface_gcse_review_path(subject: @subject)
      end
    end

    def view_path
      if gcse_qualification? && application_not_submitted_yet?
        'candidate_interface/gcse/english/grade/multiple_gcse_edit'
      else
        'candidate_interface/gcse/english/grade/edit'
      end
    end

    def gcse_qualification?
      gcse_english_qualification.qualification_type == 'gcse'
    end

    def application_not_submitted_yet?
      @current_application.submitted_at.nil?
    end

    def gcse_english_qualification
      @gcse_english_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end

    def english_gcse_grade_form
      @english_gcse_grade_form ||= EnglishGcseGradeForm.build_from_qualification(gcse_english_qualification)
    end

    def set_subject
      @subject = 'english'
    end
  end
end
