module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ProviderSelectionController < ::CandidateInterface::ContinuousApplicationsController
        before_action :available_providers, only: %i[new create]

        def new
          @wizard = CourseSelectionWizard.new(current_step:)
        end

        def create
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params: params,
          )

          if @wizard.valid_step?
            redirect_to @wizard.next_step_path(provider_id: @wizard.current_step.provider_id)
          else
            # display some validation flash errors?
            render :new
          end
        end

      private

        def current_step
          :provider_selection
        end

        def available_providers
          @available_providers ||= Provider
                                     .joins(:courses)
                                     .where(courses: { recruitment_cycle_year: RecruitmentCycle.current_year, exposed_in_find: true })
                                     .order(:name)
                                     .distinct

          @provider_cache_key = "provider-list-#{Provider.maximum(:updated_at)}"
        end
      end
    end
  end
end
