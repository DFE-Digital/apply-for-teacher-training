module CandidateInterface
  class Gcse::TypeController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern
    before_action :redirect_to_application_form_if_current_qualification_missing, only: %i[edit update]

    def new
      @type_form = if current_qualification
                     GcseQualificationTypeForm.build_from_qualification(current_qualification)
                   else
                     GcseQualificationTypeForm.new(
                       subject: subject_param,
                       level: ApplicationQualification.levels[:gcse],
                     )
                   end
    end

    def create
      @type_form = GcseQualificationTypeForm.new(qualification_params)

      if (current_qualification && @type_form.update(current_qualification)) || @type_form.save(current_application)
        redirect_to next_gcse_path
      else
        track_validation_error(@type_form)
        render :new
      end
    end

    def edit
      @type_form = GcseQualificationTypeForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def update
      @type_form = GcseQualificationTypeForm.new(qualification_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @type_form.update(current_qualification)
        return redirect_to candidate_interface_application_review_path if redirect_back_to_application_review_page?

        redirect_to candidate_interface_gcse_review_path
      else
        track_validation_error(@type_form)
        render :edit
      end
    end

  private

    def next_gcse_path
      if non_uk_qualification?
        candidate_interface_gcse_details_new_institution_country_path
      elsif !@type_form.missing_qualification?
        resolve_gcse_edit_path(@subject)
      else
        candidate_interface_gcse_review_path
      end
    end

    def qualification_params
      strip_whitespace params
        .require(:candidate_interface_gcse_qualification_type_form)
        .permit(:qualification_type, :other_uk_qualification_type, :missing_explanation, :non_uk_qualification_type)
        .merge!(
          subject: subject_param,
          level: ApplicationQualification.levels[:gcse],
        )
    end

    def non_uk_qualification?
      current_qualification.qualification_type == 'non_uk'
    end

    def redirect_to_application_form_if_current_qualification_missing
      if current_qualification.blank?
        redirect_to candidate_interface_application_form_path
      end
    end
  end
end
