module CandidateInterface
  module CourseFeeRowHelper
    def course_fee_row(course)
      return unless course.fee?

      {
        key: I18n.t('course_fee_row_helper.course_fee'),
        value: domestic_fee(course) + international_fee(course),
      }
    end

    def domestic_fee(course)
      return '' if course.fee_domestic.blank?

      tag.p(
        I18n.t(
          'course_fee_row_helper.domestic_fee',
          fee: number_to_currency(course.fee_domestic),
        ),
        class: 'govuk-body',
      )
    end

    def international_fee(course)
      return '' if course.fee_international.blank?

      tag.p(
        I18n.t(
          'course_fee_row_helper.international_fee',
          fee: number_to_currency(course.fee_international),
        ),
        class: 'govuk-body',
      )
    end
  end
end
