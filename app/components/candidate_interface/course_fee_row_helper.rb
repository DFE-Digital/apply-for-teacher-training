module CandidateInterface
  module CourseFeeRowHelper
    def course_fee_row(application_choice, course)
      return unless course.fee?

      {
        key: I18n.t('course_fee_row_helper.course_fee'),
        value: domestic_fee(course) + international_fee(course) +
          funding_advise(application_choice, course),
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

    def funding_advise(application_choice, course)
      return '' unless application_choice.application_form.international_applicant? &&
                       !(Subject.languages.intersect?(course.subjects) || Subject.physics.intersect?(course.subjects))

      content_tag :p, class: 'govuk-body secondary-text' do
        concat(
          content_tag(:span, I18n.t('course_fee_row_helper.non_uk_citizens_are_unlikely_to_get_help_funding')),
        )
        concat(
          govuk_link_to(
            I18n.t(
              'course_fee_row_helper.funding_for_non_uk_citizens',
            ),
            'https://getintoteaching.education.gov.uk/non-uk-teachers/fees-and-funding-for-non-uk-trainees',
            no_visited_state: true,
            new_tab: true,
            target: '_blank',
          ),
        )
      end
    end
  end
end
