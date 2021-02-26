module SupportInterface
  class CandidateEmailSendCountsExport
    def data_for_export
      emails_with_total_send_counts.map do |send_count_record|
        {
          'Email' => send_count_record.mail_template,
          'Send count' => send_count_record.send_count,
          'Last sent at' => send_count_record.last_sent_at,
          'Unique recipients' => send_count_record.unique_recipients,
        }
      end
    end

  private

    def emails_with_total_send_counts
      Email
        .select(
          'mail_template, COUNT(mail_template) AS send_count, COUNT(DISTINCT "to") AS unique_recipients, MAX(created_at) AS last_sent_at',
        )
        .group('mail_template')
        .order('mail_template ASC')
    end
  end
end
