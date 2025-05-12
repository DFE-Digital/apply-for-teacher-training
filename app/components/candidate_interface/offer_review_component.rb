module CandidateInterface
  class OfferReviewComponent < SummaryListComponent
    include ApplicationHelper
    def initialize(course_choice:)
      @course_choice = course_choice
    end

    def rows
      [
        provider_row,
        course_row,
        (salary_row if @course_choice.current_course.salary_details),
        (fee_row if @course_choice.current_course.fee?),
        (location_row unless @course_choice.school_placement_auto_selected?),
        (ske_conditions_row if @course_choice.offer.ske_conditions.any?),
        (reference_condition_row if @course_choice.offer.reference_condition.present?),
        (conditions_row if @course_choice.offer.conditions.any?),
      ].compact
    end

  private

    attr_reader :course_choice

    def provider_row
      {
        key: 'Provider',
        value: @course_choice.current_course.provider.name,
      }
    end

    def course_row
      {
        key: 'Course',
        value: course_row_value,
      }
    end

    def fee_row
      {
        key: 'Fees',
        value: fee_row_value,
      }
    end

    def salary_row
      {
        key: 'Salary',
        value: salary_row_value,
      }
    end

    def location_row
      {
        key: 'Location',
        value: @course_choice.current_course_option.site.name,
      }
    end

    def conditions_row
      {
        key: 'Conditions',
        value: render(OfferConditionsReviewComponent.new(conditions: @course_choice.offer.non_structured_conditions_text, provider: @course_choice.current_course.provider.name, application_form: @course_choice.application_form)),
      }
    end

    def ske_conditions_row
      {
        key: 'Subject knowledge enhancement course',
        value: ske_conditions_row_value,
      }
    end

    def reference_condition_row
      {
        key: 'References',
        value: render(OfferReferenceConditionReviewComponent.new(reference_condition: @course_choice.offer.reference_condition)),
      }
    end

    def ske_conditions_row_value
      if (ske_conditions = @course_choice.offer.ske_conditions).one?
        "You will need to complete #{SkeConditionPresenter.new(ske_conditions.first).course_description}"
      else
        tag.p('You will need to complete:', class: 'govuk-body') +
          tag.ul(class: 'govuk-list govuk-list--bullet') do
            safe_join(ske_conditions.map { |sc| tag.li(SkeConditionPresenter.new(sc).course_description) })
          end
      end
    end

    def course_row_value
      if timetable.after_find_closes?
        tag.p(@course_choice.current_course.name_and_code, class: 'govuk-!-margin-bottom-0') +
          tag.p(@course_choice.current_course.description_to_s, class: 'govuk-body')
      else
        govuk_link_to(
          @course_choice.current_course.name_and_code,
          @course_choice.current_course.find_url,
          target: '_blank',
          rel: 'noopener',
        ) +
          tag.p(@course_choice.current_course.description_to_s, class: 'govuk-body')
      end
    end

    def salary_row_value
      if @course_choice.current_course.salary_details
        markdown(@course_choice.current_course.salary_details)
      end
    end

    def fee_row_value
      if @course_choice.current_course.fee_details
        fee_value_row_with_fee_details
      else
        fee_value_row_without_fee_details
      end
    end

    def fee_value_row_with_fee_details
      if @course_choice.current_course.fee_international && @course_choice.current_course.fee_domestic
        tag.p("UK Students: £#{@course_choice.current_course.fee_domestic}", class: 'govuk-body') + tag.p("International Students: £#{@course_choice.current_course.fee_international}", class: 'govuk-body') + markdown(@course_choice.current_course.fee_details)
      elsif @course_choice.current_course.fee_domestic
        tag.p("UK Students: £#{@course_choice.current_course.fee_domestic}", class: 'govuk-body') + markdown(@course_choice.current_course.fee_details)
      elsif @course_choice.current_course.fee_international
        tag.p("International Students: £#{@course_choice.current_course.fee_international}", class: 'govuk-body') + markdown(@course_choice.current_course.fee_details)
      end
    end

    def fee_value_row_without_fee_details
      if @course_choice.current_course.fee_international && @course_choice.current_course.fee_domestic
        tag.p("UK Students: £#{@course_choice.current_course.fee_domestic}", class: 'govuk-body') + tag.p("International Students: £#{@course_choice.current_course.fee_international}", class: 'govuk-body')
      elsif @course_choice.current_course.fee_domestic
        tag.p("UK Students: £#{@course_choice.current_course.fee_domestic}", class: 'govuk-body')
      elsif @course_choice.current_course.fee_international
        tag.p("International Students: £#{@course_choice.current_course.fee_international}", class: 'govuk-body')
      end
    end

    def timetable
      @timetable ||= RecruitmentCycleTimetable.current_timetable
    end
  end
end
