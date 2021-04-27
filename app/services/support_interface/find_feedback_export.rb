module SupportInterface
  class FindFeedbackExport
    def data_for_export
      FindFeedback.all.order(:created_at).find_each(batch_size: 100).map do |find_feedback|
        {
          feedback_provided_at: find_feedback.created_at,
          find_url: find_url(find_feedback),
          email: find_feedback.email_address,
          feedback: find_feedback.feedback,
        }
      end
    end

  private

    def find_url(find_feedback)
      'https://www.find-postgraduate-teacher-training.service.gov.uk' + find_feedback.path
    end
  end
end
