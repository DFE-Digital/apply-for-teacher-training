module ProviderInterface
  class ApplicationChoicePresenter < SimpleDelegator
    def status_tag_text
      status.humanize.titleize
    end

    def status_tag_class
      case status
      when 'offer'
        'app-tag--offer'
      when 'rejected'
        'app-tag--rejected'
      else
        'app-tag--new'
      end
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def course_name_and_code
      course.name_and_code
    end

    def course_start_date
      course.start_date
    end

    def course_preferred_location
      course.course_options.first.site.name
    end

    def status_name
      I18n.t!("application_choice.status_name.#{status}")
    end

    def updated_at
      super.strftime('%e %b %Y %l:%M%P')
    end

    def email_address
      candidate.email_address
    end
  end
end
