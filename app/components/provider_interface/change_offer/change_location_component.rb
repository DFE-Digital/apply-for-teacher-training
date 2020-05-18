module ProviderInterface
  module ChangeOffer
    class ChangeLocationComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :change_offer_form, :application_choice, :providers

      def initialize(change_offer_form:, providers:)
        @change_offer_form = change_offer_form
        @application_choice = change_offer_form.application_choice
        @providers = providers

        if @change_offer_form.valid?
          @change_offer_form.step = @change_offer_form.next_step
        end
      end

      def course_options
        current_option = application_choice.offered_option
        CourseOption.where(
          course_id: change_offer_form.course_id,
          study_mode: current_option.study_mode, # preserving study_mode, for now
          # TODO: check vacancy_status, e.g. 'B'
        ).includes(:site).order('sites.name')
      end

      def page_title
        if application_choice.offer? && change_offer_form.entry == :course_option
          'Change location'
        else
          'Select location'
        end
      end

      def next_step_url
        request.params[:step] = change_offer_form.step
        request.params
      end

      def next_step_method
        :get
      end
    end
  end
end
