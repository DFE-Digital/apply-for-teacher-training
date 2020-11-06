class CoursesController < ApplicationController
  decorates_assigned :course

  def show
    @course = Course
      .includes(:subjects)
      .includes(site_statuses: [:site])
      .includes(provider: [:sites])
      .includes(:accrediting_provider)
      .where(recruitment_cycle_year: Settings.current_cycle)
      .where(provider_code: params[:provider_code])
      .find(params[:course_code])
      .first
  rescue JsonApiClient::Errors::NotFound
    render template: "errors/not_found", status: :not_found, formats: [:html]
  end

  def apply
    course = Course
      .includes(:provider)
      .where(recruitment_cycle_year: Settings.current_cycle)
      .where(provider_code: params[:provider_code])
      .find(params[:course_code])
      .first

    Rails.logger.info("Course apply conversion. Provider: #{course.provider.provider_code}. Course: #{course.course_code}")

    # If course provider is University of Bolton
    if course.provider.provider_code == "8N5"
      redirect_to "https://www.apply-for-teacher-training.service.gov.uk/candidate/account?providerCode=#{course.provider.provider_code}&courseCode=#{course.course_code}"
    else
      redirect_to "https://www.apply-for-teacher-training.service.gov.uk/candidate/apply?providerCode=#{course.provider.provider_code}&courseCode=#{course.course_code}"
    end
  end
end
