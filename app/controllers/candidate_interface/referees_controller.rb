module CandidateInterface
  class RefereesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_referee, only: %i[edit update confirm_destroy destroy]
    before_action :set_referees, only: %i[index review]

    def index
      unless @referees.empty?
        redirect_to candidate_interface_review_referees_path
      end
    end

    def new
      @referee = current_candidate.current_application.references.build
    end

    def create
      @referee = current_candidate.current_application
                                  .references
                                  .build(referee_params)
      if @referee.save
        redirect_to candidate_interface_review_referees_path
      else
        render :new
      end
    end

    def edit; end

    def update
      if @referee.update(referee_params)
        redirect_to candidate_interface_review_referees_path
      else
        render :edit
      end
    end

    def confirm_destroy; end

    def destroy
      @referee.destroy!
      redirect_to candidate_interface_referees_path
    end

    def review
      @application_form = current_candidate.current_application
    end

  private

    def set_referee
      @referee = current_candidate.current_application
                                    .references
                                    .find(params[:id])
    end

    def set_referees
      @referees = current_candidate.current_application
                                    .references
    end

    def referee_params
      params.require(:reference).permit(
        :name,
        :email_address,
        :relationship,
      )
        .transform_values(&:strip)
    end
  end
end
