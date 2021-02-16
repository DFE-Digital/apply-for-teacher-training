module CandidateInterface
  class Gcse::TypeController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern

    def edit
      @application_qualification = find_or_build_qualification_form
    end

    def update
      @application_qualification = find_or_build_qualification_form

      @application_qualification.set_attributes(qualification_params)

      if @application_qualification.save_base(current_candidate.current_application)
        update_gcse_completed(false)

        redirect_to next_gcse_path
      else
        track_validation_error(@application_qualification)
        render :edit
      end
    end

  private

    def find_or_build_qualification_form
      current_qualification = current_application.qualification_in_subject(:gcse, subject_param)

      if current_qualification
        GcseQualificationTypeForm.build_from_qualification(current_qualification)
      else
        GcseQualificationTypeForm.new(
          subject: subject_param,
          level: ApplicationQualification.levels[:gcse],
        )
      end
    end

    def next_gcse_path
      @details_form = GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, subject_param),
      )

      if new_non_uk_qualification?
        candidate_interface_gcse_details_edit_institution_country_path
      elsif !@application_qualification.missing_qualification? && @details_form.grade.nil?
        resolve_gcse_edit_path(@subject)
      else
        candidate_interface_gcse_review_path
      end
    end

    def qualification_params
      strip_whitespace params
        .require(:candidate_interface_gcse_qualification_type_form)
        .permit(:qualification_type, :other_uk_qualification_type, :missing_explanation, :non_uk_qualification_type)
    end

    def new_non_uk_qualification?
      @application_qualification.qualification_type == 'non_uk' &&
        @details_form.qualification.institution_country.nil?
    end
  end
end
