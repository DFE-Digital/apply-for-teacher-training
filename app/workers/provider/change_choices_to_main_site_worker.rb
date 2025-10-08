class Provider::ChangeChoicesToMainSiteWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform(choice_ids, main_site_id)
    choices = ApplicationChoice.where(id: choice_ids)
    main_site = Site.find_by(id: main_site_id)

    if choices.present? && main_site.present?
      choices.each do |choice|
        ActiveRecord::Base.transaction do
          new_course_option = choice.current_course.course_options.joins(:site)
            .find_by(site: { id: main_site.id })

          if new_course_option.present?
            choice.update_course_option_and_associated_fields!(
              new_course_option,
              audit_comment: "Worker change_choices_to_main_site ran at #{Time.zone.now}",
            )
          end
        end
      end
    end
  end
end
