module CandidateInterface
  class SectionPolicy
    attr_accessor :current_application, :controller_path, :action_name, :params

    def initialize(current_application:, controller_path:, action_name:, params:)
      @current_application = current_application
      @controller_path = controller_path
      @action_name = action_name
      @params = params
    end

    def can_edit?
      any_offer_accepted? ||
        all_applications_unsubmitted? ||
        editable_section? ||
        temporarily_editable_section?
    end

    def personal_statement?
      @controller_path.classify.eql?('CandidateInterface::PersonalStatement')
    end

  private

    delegate :any_offer_accepted?, to: :current_application

    def all_applications_unsubmitted?
      current_application.application_choices.all?(&:unsubmitted?)
    end

    def editable_section?
      Section.editable.any? do |section|
        controller_match = section_match_with_controller(section)

        if controller_match.present? && section.editable_condition.present?
          section.editable_condition.call(section, self)
        else
          controller_match
        end
      end
    end

    def temporarily_editable_section?
      @current_application.editable_sections? &&
        @current_application.editable_until? &&
        Time.zone.now < @current_application.editable_until &&
        editable_section_via_support_match?
    end

    def editable_section_via_support_match?
      Section.all.any? do |section|
        controller_match = section_match_with_controller(section)

        controller_match && section.id.in?(current_application_editable_sections)
      end
    end

    def section_match_with_controller(section)
      @controller_path.classify =~ /#{section.controller}/
    end

    def current_application_editable_sections
      @current_application.editable_sections.map(&:to_sym)
    end
  end
end
