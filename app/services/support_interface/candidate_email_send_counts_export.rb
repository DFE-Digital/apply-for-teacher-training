module SupportInterface
  class CandidateEmailSendCountsExport
    def data_for_export
      emails_with_total_send_counts.map do |send_count_record|
        unique_recipients = unique_recipients_hash[send_count_record.mail_template]
        {
          'Email' => send_count_record.mail_template,
          'Send count' => send_count_record.send_count,
          'Last sent at' => send_count_record.last_sent_at,
          'Unique recipients' => unique_recipients,
        }
      end
    end

  private

    def unique_recipients_per_email
      distinct_mail_templates_and_recipients = Email.select('DISTINCT "to", "mail_template"').to_sql
      Email
        .select('mail_template, COUNT(mail_template) AS unique_recipients')
        .from("(#{distinct_mail_templates_and_recipients}) AS template_recipient_combos GROUP BY template_recipient_combos.mail_template")
    end

    def unique_recipients_hash
      unique_recipients_per_email.each_with_object({}) do |recipient_count_record, hash|
        hash[recipient_count_record.mail_template] = recipient_count_record.unique_recipients
      end
    end

    def emails_with_total_send_counts
      Email
        .select(
          'mail_template, COUNT(mail_template) AS send_count, MAX(created_at) AS last_sent_at',
        )
        .group('mail_template')
        .order('mail_template ASC')
    end
  end
end
