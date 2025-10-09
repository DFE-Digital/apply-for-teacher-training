class Provider::ChangeChoicesToMainSiteWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform(choice_ids)
    choices = ApplicationChoice.where(id: choice_ids)

    if choices.present?
      choices.each do |choice|
        ActiveRecord::Base.transaction do
          new_course_option = choice.current_course.course_options.joins(:site).find_by(
            study_mode: choice.current_course_option.study_mode,
            site: { code: '-' },
          )

          if new_course_option.present?
            choice.update!(
              current_course_option: new_course_option,
              course_option: new_course_option,
              current_recruitment_cycle_year: new_course_option.course.recruitment_cycle_year,
              audit_comment: "Worker change_choices_to_main_site ran at #{Time.zone.now}",
            )
          end
        end
      end
    end
  end
end
