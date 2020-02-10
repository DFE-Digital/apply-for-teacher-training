module SupportInterface
  class ReferenceWithFeedbackComponent < ActionView::Component::Base
    validates :reference, presence: true

    delegate :feedback,
             :name,
             :email_address,
             :relationship,
             :feedback_status,
             :consent_to_be_contacted,
             to: :reference

    def initialize(reference:, title: '')
      @reference = reference
      @title = title
    end

    def rows
      [
        status_row,
        date_rows,
        name_row,
        email_address_row,
        relationship_row,
        consent_row,
        feedback_row,
      ].flatten.compact
    end

  private

    def status_row
      {
        key: 'Reference status',
        value: render(TagComponent,
                      text: t("reference_status.#{feedback_status}"),
                      type: feedback_tag_color(feedback_status)),
      }
    end

    def date_rows
      [
        {
          key: 'Requested on',
          value: reference.requested_at&.to_s(:govuk_date_and_time),
        },
        {
          key: 'Chase on',
          value: reference.chase_referee_at&.to_s(:govuk_date_and_time),
        },
        {
          key: 'Replace on',
          value: reference.replace_referee_at&.to_s(:govuk_date_and_time),
        },
      ].select { |row| row[:value] }
    end

    def name_row
      {
        key: 'Name',
        value: name,
      }
    end

    def email_address_row
      {
        key: 'Email address',
        value: email_address,
      }
    end

    def relationship_row
      {
        key: 'Relationship to candidate',
        value: relationship,
      }
    end

    def feedback_row
      if feedback
        {
          key: 'Reference',
          value: feedback,
        }
      end
    end

    def consent_row
      if feedback
        {
          key: 'Given consent for research?',
          value: consent_to_be_contacted_present,
        }
      end
    end

    def consent_to_be_contacted_present
      return ' - ' if consent_to_be_contacted.nil?

      consent_to_be_contacted == true ? 'Yes' : 'No'
    end

    def feedback_tag_color(feedback_status)
      feedback_status == 'feedback_refused' ? 'red' : 'blue'
    end

    attr_reader :reference, :title
  end
end
