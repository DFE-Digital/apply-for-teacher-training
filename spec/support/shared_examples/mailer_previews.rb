RSpec.shared_examples_for 'mailer previews' do |preview_class|
  let(:emails) { described_class.instance_methods(false) }
  let(:preview_emails) { preview_class.instance_methods(false) }
  let(:preview_emails_with_exact_names) { emails.intersection preview_emails }
  let(:possible_emails_not_included) { preview_emails - preview_emails_with_exact_names }
  let(:emails_with_prefix) do
    possible_emails_not_included.select do |method_name|
      # Many preview emails can have the prefix as the real mailer email name
      # e.g new_cycle_has_started and in preview
      # new_cycle_has_started_with_no_first_name_and_unsubmitted_application
      preview_emails.grep(/^#{method_name}/).present?
    end
  end
  let(:not_included_emails) { possible_emails_not_included - emails_with_prefix }

  it 'include emails in preview' do
    expect(not_included_emails).to be_blank
  end

  it 'has a description for each email in the support console' do
    class_key = preview_class.to_s.gsub('::', '').gsub('Preview', '').underscore
    preview_emails.each do |email|
      expect(
        I18n.t("support_interface.docs.mailer_previews.email_descriptions.#{class_key}.#{email}"),
      ).not_to be_nil
    end
  end
end
