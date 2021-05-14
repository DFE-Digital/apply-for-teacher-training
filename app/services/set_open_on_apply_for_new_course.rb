class SetOpenOnApplyForNewCourse
  include Rails.application.routes.url_helpers

  def initialize(course)
    @course = course
  end

  def call
    @course.open! if HostingEnvironment.sandbox_mode? || @course.in_previous_cycle&.open_on_apply?

    if @course.provider.any_open_courses_in_current_cycle?
      auto_open = @course.provider.all_courses_open_in_current_cycle?(exclude_ratified_courses: true)

      @course.open! if auto_open

      notify_of_new_course!(@course.provider, @course.accredited_provider, auto_open)
    end
  end

private

  def notify_of_new_course!(provider, accredited_provider, auto_open)
    notification = [":seedling: #{provider.name}, which has courses open on Apply, added a new course"]

    if auto_open
      notification << 'We opened it automatically'
    else
      notification << 'We didn’t automatically open it'
    end

    if accredited_provider&.onboarded?
      notification << "It’s ratified by #{accredited_provider.name}, who have signed the DSA"
    elsif accredited_provider.present?
      notification << "It’s ratified by #{accredited_provider.name}, who have NOT signed the DSA"
    else
      notification << 'There’s no separate accredited body for this course'
    end

    SlackNotificationWorker.perform_async(
      notification.join('. ') + '.',
      support_interface_course_url(@course),
    )
  end
end
