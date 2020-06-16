module CandidateInterface
  class Degrees::GradeController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      @degree_grade_form = DegreeGradeForm.new(degree: degree)
    end

    def create
      @degree_grade_form = DegreeGradeForm.new(grade_params)

      if @degree_grade_form.save
        redirect_to candidate_interface_degree_year_path(degree)
      else
        render :new
      end
    end

    def edit
      current_qualification = current_application.application_qualifications.degrees.find(current_degree_id)
      @degree = DegreeForm.build_from_qualification(current_qualification)
    end

    def update
      @degree = DegreeForm.new(id: current_degree_id, attributes: degree_params)

      if @degree.update_grade(current_application)
        if award_year_nil?
          redirect_to candidate_interface_degrees_year_path(current_degree_id)
        else
          current_application.update!(degrees_completed: false)

          redirect_to candidate_interface_degrees_review_path
        end
      else
        track_validation_error(@degree)
        render :new
      end
    end

  private

    def degree
      @degree = ApplicationQualification.find(params[:id])
    end

    def grade_params
      params
        .require(:candidate_interface_degree_grade_form)
        .permit(:grade, :other_grade, :predicted_grade)
        .transform_values(&:strip)
        .merge(degree: degree)
    end

    def award_year_nil?
      current_application.application_qualifications.find(current_degree_id).award_year.nil?
    end
  end
end
