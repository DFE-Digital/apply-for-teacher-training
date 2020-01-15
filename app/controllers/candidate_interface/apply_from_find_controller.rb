module CandidateInterface
  # The Apply from Find page is the landing page for candidates coming from the
  # Find postgraduate teacher training (https://find-postgraduate-teacher-training.education.gov.uk/)
  class ApplyFromFindController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

    rescue_from ActionController::ParameterMissing, with: :render_not_found

    def show
      begin
        provider = Provider.find_by!(code: params.fetch(:providerCode))
        @course = provider.courses.where(exposed_in_find: true).find_by!(code: params.fetch(:courseCode))

        if @course.open_on_apply? && FeatureFlag.active?('pilot_open')
          render :apply_on_ucas_or_apply
        else
          render :apply_on_ucas_only
        end
      rescue ActiveRecord::RecordNotFound
        provider_code = params.fetch(:providerCode)
        course_code = params.fetch(:courseCode)

        @course = FindAPI::Course.fetch(provider_code, course_code)

        if @course.nil?
          render_not_found
        else
          render :apply_on_ucas_only
        end
      end
    end

  private

    def render_not_found
      render :not_found, status: :not_found
    end
  end
end
