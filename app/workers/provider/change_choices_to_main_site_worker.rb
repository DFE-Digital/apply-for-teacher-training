class Provider::ChangeChoicesToMainSiteWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform(choice_ids, main_site_id)
    choices = ApplicationChoice.where(id: choice_ids)
    main_site = Site.find_by(id: main_site_id)

    if choices.present? && main_site.present?
      choices.each do |choice|
        ActiveRecord::Base.transaction do
          study_mode = choice.current_course_option.study_mode
          new_course_option = choice.current_course.course_options.joins(:site)
            .find_by(study_mode:, site: { id: main_site.id })

          if new_course_option.present?
            update_all_course_option_attributes!(
              new_course_option,
              application_choice: choice,
              audit_comment: "Worker change_choices_to_main_site ran at #{Time.zone.now}",
            )
          end
        end
      end
    end
  end

private

  def update_all_course_option_attributes!(new_course_option, application_choice:, audit_comment: nil)
    attrs = {
      current_course_option: new_course_option,
      course_option: new_course_option,
      original_course_option: new_course_option,
      current_recruitment_cycle_year: new_course_option.course.recruitment_cycle_year,
    }
    attrs.merge!(audit_comment:) if audit_comment.present?

    application_choice.update!(attrs)
  end
end
