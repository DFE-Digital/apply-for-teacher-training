module ProviderInterface
  module ChangeOffer
    class ChangeLocationComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :change_offer_form, :application_choice

      def initialize(change_offer_form:)
        @change_offer_form = change_offer_form
        @application_choice = change_offer_form.application_choice

        if @change_offer_form.valid?
          @change_offer_form.step = @change_offer_form.next_step
        end

        preselect_same_site_if_available
      end

      def course_options
        CourseOption.where(
          course_id: change_offer_form.course_id,
          study_mode: change_offer_form.study_mode,
          # TODO: check vacancy_status, e.g. 'B'
        ).includes(:site).order('sites.name')
      end

      def preselect_same_site_if_available
        if change_offer_form.course_option_id
          previous_option = CourseOption.find(change_offer_form.course_option_id)
          new_option = course_options.find_by(site_id: previous_option.site.id)
          change_offer_form.course_option_id = new_option.id if new_option
        end
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
