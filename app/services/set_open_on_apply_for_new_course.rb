class SetOpenOnApplyForNewCourse
  include Rails.application.routes.url_helpers

  def initialize(course)
    @course = course
  end

  def call
    @course.open! if HostingEnvironment.sandbox_mode? || @course.in_previous_cycle&.open_on_apply?

    if @course.provider.any_courses_open_in_current_cycle?(exclude_ratified_courses: true)
      auto_open = @course.provider.all_courses_open_in_current_cycle?(exclude_ratified_courses: true)

      @course.open! if auto_open

      notify_of_new_course!(@course.provider, @course.accredited_provider, auto_open)
    end
  end

private

  def notify_of_new_course!(provider, accredited_provider, auto_open)
    notification = [":seedling: #{provider.name}, which has courses open on Apply, added #{@course.name_and_code}"]
    notification << auto_open_message(auto_open)
    notification << accredited_body_message(accredited_provider)

    SlackNotificationWorker.perform_async(
      "#{notification.join('. ')}.",
      support_interface_course_url(@course),
    )
  end

  def auto_open_message(auto_open)
    auto_open ? 'We opened it automatically' : 'We didn’t automatically open it'
  end

  def accredited_body_message(accredited_provider)
    if accredited_provider&.onboarded?
      "It’s ratified by #{accredited_provider.name}, who have signed the DSA"
    elsif accredited_provider.present?
      "It’s ratified by #{accredited_provider.name}, who have NOT signed the DSA"
    else
      'There’s no separate accredited body for this course'
    end
  end
end
