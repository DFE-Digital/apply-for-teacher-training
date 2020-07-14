class ProviderEmailsForApplicationChoices
  def initialize(choice_ids)
    @choice_ids = choice_ids
  end

  def as_hash
    @_as_hash ||= @choice_ids.reduce({}, &method(:choice_reducer))
  end

  def as_csv
    require 'csv'

    CSV.generate do |csv|
      csv << ['email address', 'name', 'affected applications']

      as_hash.each do |(email, attrs)|
        csv << [email, attrs[:name], attrs[:affected_applications].join("\n")]
      end
    end
  end

private

  def choice_to_string(choice)
    name = choice.application_form.full_name
    ref = choice.application_form.support_reference
    status = I18n.t("provider_application_states.#{choice.status}")
    url = "https://www.apply-for-teacher-training.service.gov.uk/provider/applications/#{choice.id}"
    "* #{name} (#{ref}) (#{status}) — #{url}"
  end

  # build a hash like this
  # { email@example.com: {name: "Bob Example", affected_applications: ["* Ella Candidate (ABC123) (Rejected) - http://..."]}}
  def choice_reducer(emails_to_choices, choice_id)
    choice = ApplicationChoice.find(choice_id)
    affected_providers = [choice.course.provider, choice.course.accredited_provider].compact
    interested_users = affected_providers.flat_map(&:provider_users).uniq

    interested_users.each do |user|
      emails_to_choices[user.email_address] ||= { name: (user.full_name or 'Colleague'), affected_applications: [] }
      emails_to_choices[user.email_address][:affected_applications].push(choice_to_string(choice))
    end

    emails_to_choices
  end
end
