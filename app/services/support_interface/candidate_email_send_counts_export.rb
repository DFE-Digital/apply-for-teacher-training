module SupportInterface
  class CandidateEmailSendCountsExport
    def data_for_export
      emails_with_counts.map do |email_hash|
        {
          'Email' => email_hash['mail_template'],
          'Send count' => email_hash['send_count'],
          'Last sent at' => email_hash['last_sent_at'],
        }
      end
    end

  private

    def emails_with_counts
      Email
        .select(
          'mail_template, COUNT(mail_template) AS send_count, MAX(created_at) AS last_sent_at',
        )
        .group('mail_template')
        .order('mail_template ASC')
    end
  end
end
