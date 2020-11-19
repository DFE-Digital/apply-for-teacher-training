module CandidateInterface
  class Gcse::Maths::GradeController < CandidateInterfaceController
    include Gcse::GradeControllerConcern

    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def edit
      @application_qualification = maths_gsce_grade_form
      @qualification_type = maths_gsce_grade_form.qualification.qualification_type
    end

    def update
      @qualification_type = maths_gsce_grade_form.qualification.qualification_type

      maths_gsce_grade_form.grade = maths_params[:grade]
      maths_gsce_grade_form.other_grade = maths_params[:other_grade]

      @application_qualification = maths_gsce_grade_form.save_grade

      if @application_qualification
        update_gcse_completed(false)
        redirect_to next_gcse_path
      else
        @application_qualification = maths_gsce_grade_form
        track_validation_error(@application_qualification)

        render :edit
      end
    end

  private

    def set_subject
      @subject = 'maths'
    end

    def next_gcse_path
      if maths_gsce_grade_form.award_year.nil?
        candidate_interface_gcse_details_edit_year_path(subject: @subject)
      else
        candidate_interface_gcse_review_path(subject: @subject)
      end
    end

    def maths_params
      params.require(:candidate_interface_gcse_qualification_details_form).permit(%i[grade award_year other_grade])
    end

    def maths_gsce_grade_form
      @maths_gcse_grade_form ||= GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, @subject),
      )
    end
  end
end
