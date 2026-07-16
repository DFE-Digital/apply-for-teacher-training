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

    def current_qualification
      @current_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end

    def set_institution_country
      @institution_country ||= current_qualification.institution_country
    end

    def set_equivalent_qualifications
      return if @institution_country.blank?

      @equivalent_qualifications ||= finder.equivalent_qualifications
    end

    def set_selected_equivalent_qualification
      return if current_qualification.non_uk_qualification_type.blank? || finder.blank?

      @selected_equivalent_qualification =
        finder.equivalent_qualifications.find do |qual|
          qual.name == current_qualification.non_uk_qualification_type
        end
    end

    def selected_grade_schema
      @selected_grade_schema ||=
        if current_qualification.selected_grade_schema_id.present?
          @grade_schemas.find do |schema|
            schema.id == current_qualification.selected_grade_schema_id
          end
        elsif @grade_schemas.one?
          @grade_schemas.first
        end
    end

    def set_grade_schemas
      @grade_schemas ||=
        if @selected_equivalent_qualification.blank?
          []
        else
          @selected_equivalent_qualification.grade_schemas
        end
    end

    def set_structured_grades
      @structured_grades ||=
        if selected_grade_schema.present?
          selected_grade_schema.passing_grades +
            selected_grade_schema.failing_grades
        else
          []
        end
    end

    def finder
      return if @institution_country.blank?

      @finder ||= InternationalQualifications::StructuredGcseOptionFinder.new(@institution_country, @subject)
    end

    def redirect_if_feature_flag_inactive
      return if FeatureFlag.active?('2027_international_qualifications_flow')

      redirect_to root_path
    end

    def subject_param
      params.require(:subject)
    end
  end
end
