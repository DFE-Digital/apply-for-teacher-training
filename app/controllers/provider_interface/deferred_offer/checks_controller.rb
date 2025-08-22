module ProviderInterface
  module DeferredOffer
    class ChecksController < ProviderInterface::ProviderInterfaceController
      class DeferredOfferForm
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :course_id
        attribute :location_id
        attribute :study_mode
        attribute :conditions_status

        attribute :conditions, readonly: true
        attribute :application_choice, readonly: true

        def course
          Course.find_by(id: course_id)
        end

        def location
          Site.find_by(id: location_id)
        end
      end

      def show
        application_choice = GetApplicationChoicesForProviders.call(
          providers: current_provider_user.providers,
        ).find(params[:application_choice_id])

        @deferred_offer = DeferredOfferForm.new(
          course_id: application_choice.current_course.id,
          location_id: application_choice.current_site.id,
          study_mode: application_choice.current_course_option.study_mode,
          conditions: application_choice.offer&.conditions || [],
          application_choice: application_choice,
        )
      end
    end
  end
end
