module CandidateInterface
  class Degrees::YearController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      @degree_year_form = DegreeYearForm.new(degree: degree)
    end

    def create
      @degree_year_form = DegreeYearForm.new(degree_year_params)

      if @degree_year_form.save
        redirect_to candidate_interface_degrees_review_path
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

      if @degree.update_year(current_application)
        current_application.update!(degrees_completed: false)

        redirect_to candidate_interface_degrees_review_path
      else
        track_validation_error(@degree)
        render :new
      end
    end

  private

    def degree
      @degree = ApplicationQualification.find(params[:id])
    end

    def current_degree_id
      params.permit(:id)[:id]
    end

    def degree_year_params
      params
        .require(:candidate_interface_degree_year_form)
        .permit(:start_year, :award_year)
        .transform_values(&:strip)
        .merge(degree: degree)
    end
  end
end
