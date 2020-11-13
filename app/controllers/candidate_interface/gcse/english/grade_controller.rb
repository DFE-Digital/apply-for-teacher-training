module CandidateInterface
  class Gcse::English::GradeController < Gcse::DetailsController
    include Gcse::GradeControllerConcern

    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def edit
      @gcse_grade_form = english_gcse_grade_form
      @qualification_type = gcse_english_qualification.qualification_type

      render view_path
    end

    def update
      if multiple_gsces_are_active?
        @gcse_grade_form = english_gcse_grade_form.assign_values(english_details_params)
      else
        @qualification_type = gcse_english_qualification.qualification_type
        @gcse_grade_form = english_gcse_grade_form
        @gcse_grade_form.grade = english_details_params[:grade]
        @gcse_grade_form.other_grade = english_details_params[:other_grade]
      end

      save_successful = multiple_gsces_are_active? ? @gcse_grade_form.save_grades : @gcse_grade_form.save_grade

      if save_successful
        update_gcse_completed(false)
        redirect_to next_gcse_path
      else
        track_validation_error(@gcse_grade_form)
        render view_path
      end
    end

  private

    def english_details_params
      params.require(:candidate_interface_english_gcse_grade_form).permit([
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

    def view_path
      if gcse_qualification? && multiple_gsces_are_active? && application_not_submitted_yet?
        'candidate_interface/gcse/english/grade/multiple_gcse_edit'
      else
        'candidate_interface/gcse/english/grade/edit'
      end
    end

    def gcse_qualification?
      gcse_english_qualification.qualification_type == 'gcse'
    end

    def multiple_gsces_are_active?
      FeatureFlag.active?('multiple_english_gcses')
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
