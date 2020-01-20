module CandidateInterface
  class RequestReference
    attr_accessor :referee_params, :referee

    def initialize(referee_params)
      self.referee_params = referee_params
    end

    def call
      @referee = current_candidate.current_application
                                  .application_references
                                  .build(referee_params)
      @referee.save
    end
  end

  class RefereesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable
    before_action :redirect_to_review_referees_if_amendable, except: %i[index review]
    before_action :set_referee, only: %i[edit update confirm_destroy destroy]
    before_action :set_referees, only: %i[index review]

    def index
      unless @referees.empty?
        redirect_to candidate_interface_review_referees_path
      end
    end

    def new
      @referee = current_candidate.current_application.application_references.build
    end

    def create
      if request_reference_service.call
        redirect_to candidate_interface_review_referees_path
      else
        @referee = request_reference_service.referee
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
                                    .application_references
                                    .includes(:application_form)
                                    .find(params[:id])
    end

    def set_referees
      @referees = current_candidate.current_application
                                    .application_references
                                    .includes(:application_form)
    end

    def referee_params
      params.require(:application_reference).permit(
        :name,
        :email_address,
        :relationship,
      )
        .transform_values(&:strip)
    end

    def redirect_to_review_referees_if_amendable
      redirect_to candidate_interface_review_referees_path if current_application.amendable?
    end

    def request_reference_service
      @request_reference_service ||= RequestReference.new(referee_params)
    end
  end
end
