module SupportInterface
  class CandidateEmailSendCountsExport
    def data_for_export
      emails_with_total_send_counts.map do |send_count_record|
        {
          email_template: send_count_record.mail_template,
          send_count: send_count_record.send_count,
          last_sent_at: send_count_record.last_sent_at,
          unique_recipients: send_count_record.unique_recipients,
          mailer: send_count_record.mailer.humanize,
        }
      end
    end

  private

    def emails_with_total_send_counts
      Email
        .select(
          'mail_template, COUNT(mail_template) AS send_count, COUNT(DISTINCT "to") AS unique_recipients, MAX(created_at) AS last_sent_at, mailer',
        )
        .group('mail_template, mailer')
        .order('mail_template ASC')
    end
  end
end
