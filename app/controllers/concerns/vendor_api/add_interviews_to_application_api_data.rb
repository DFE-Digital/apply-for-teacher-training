module VendorAPI
  module AddInterviewsToApplicationAPIData
    def schema
      super.deep_merge!({
        attributes: {
          interviews: interviews.map { |interview| InterviewPresenter.new(active_version, interview).schema },
        },
      })
    end

    def interviews
      application_choice.interviews.order(updated_at: :desc)
    end
  end
end
