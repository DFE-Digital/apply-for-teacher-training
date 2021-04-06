module ProviderInterface
  module ChangeOffer
    class ConfirmComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :change_offer_form, :application_choice, :completion_url

      def initialize(change_offer_form:, completion_url:)
        @change_offer_form = change_offer_form
        @application_choice = change_offer_form.application_choice
        @completion_url = completion_url

        if @change_offer_form.valid?
          @change_offer_form.step = @change_offer_form.next_step
        end
      end

      def future_application_choice
        if change_offer_form.course_option_id
          future_application_choice = application_choice.dup
          future_application_choice.current_course_option_id = change_offer_form.course_option_id
          future_application_choice
        else
          application_choice
        end
      end

      def study_modes
        Course.find(change_offer_form.course_id).available_study_modes_from_options
      end

      def change_path_options
        entry = change_offer_form.entry
        {
          change_provider_path: (params_for_step(:provider) if entry == 'provider'),
          change_course_path: (params_for_step(:course) if %w[provider course].include? entry),
          change_study_mode_path: (params_for_step(:study_mode) if study_modes.count > 1),
          change_course_option_path: params_for_step(:course_option),
        }
      end

      def params_for_step(step_symbol)
        new_form_hash = {
          provider_id: change_offer_form.provider_id,
          course_id: change_offer_form.course_id,
          study_mode: change_offer_form.study_mode,
          course_option_id: change_offer_form.course_option_id,
          entry: change_offer_form.entry,
          step: step_symbol,
        }
        request.params.merge step: step_symbol, provider_interface_change_offer_form: new_form_hash
      end

      def page_title
        'Check and confirm changes to offer'
      end

      def next_step_url
        completion_url
      end

      def next_step_method
        :patch
      end
    end
  end
end
