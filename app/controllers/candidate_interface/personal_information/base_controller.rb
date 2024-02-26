module CandidateInterface
  module PersonalInformation
    class BaseController < ::CandidateInterface::ContinuousApplicationsController
      def new
        @wizard = PersonalInformationWizard.new(
          current_step:,
          step_params:,
          current_application:,
        )
      end

      def edit
        @wizard = PersonalInformationWizard.new(
          current_step:,
          step_params: update_params,
          current_application:,
          application_choice:,
          edit: true,
        )
      end

      def create
        @wizard = PersonalInformationWizard.new(
          current_step:,
          step_params:,
          current_application:,
        )

        if @wizard.save
          redirect_to @wizard.next_step_path
        else
          render :new
        end
      end

      def update
        @wizard = PersonalInformationWizard.new(
          current_step:,
          step_params:,
          current_application:,
          edit: true,
        )

        if @wizard.update
          redirect_to @wizard.next_step_path
        else
          render :edit
        end
      end

      def current_step
        raise NotImplementedError
      end

      def step_params
        params
      end
    end
  end
end
