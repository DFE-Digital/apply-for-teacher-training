module CandidateInterface
  class Gcse::NewInternationalFlow::BaseController < SectionController
    include GcseStatementComparabilityPathHelper

    before_action :redirect_if_feature_flag_inactive
    before_action :set_subject
    before_action :set_institution_country
    before_action :set_equivalent_qualifications
    before_action :set_selected_equivalent_qualification
    before_action :set_grade_schemas
    before_action :set_structured_grades
    before_action :render_application_feedback_component

  private

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end

    def current_qualification
      @current_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end

    def structured_data_countries
      @structured_data_countries ||= %w[GH NG KE SL GM LR]
    end

    def multiple_grade_schemas_available?
      # For use in post-MVP schemas step
      @grade_schemas.present? && @grade_schemas.size > 1
    end

    def set_institution_country
      @institution_country ||= current_qualification.institution_country
    end

    def set_equivalent_qualifications
      return if @institution_country.blank?

      @equivalent_qualifications ||= finder.equivalent_qualifications
    end

    def set_selected_equivalent_qualification
      return if current_qualification.non_uk_qualification_type.blank?
      return if finder.blank?

      @selected_equivalent_qualification =
        finder.equivalent_qualifications.find do |qual|
          qual.name == current_qualification.non_uk_qualification_type
        end
    end

    def set_structured_grades
      # post-MVP we will map through the available schemas if there is more than one and present them for selection in an intermediary step
      # We can then use that value to present the relevant structured grades for the chosen schema rather than simply 'first'
      @structured_grades ||=
        if @selected_equivalent_qualification.blank?
          []
        else
          @grade_schemas.first.passing_grades + @grade_schemas.first.failing_grades
        end
    end

    def set_grade_schemas
      @grade_schemas ||=
        if @selected_equivalent_qualification.blank?
          []
        else
          @grade_schemas ||= finder.grade_schemas(@selected_equivalent_qualification)
        end
    end

    def finder
      return if @institution_country.blank?

      @finder ||= InternationalQualifications::StructuredGcseOptionFinder.new(@institution_country)
    end

    def redirect_if_feature_flag_inactive
      return if FeatureFlag.active?('2027_international_qualifications_flow')

      redirect_to root_path
    end
  end
end
