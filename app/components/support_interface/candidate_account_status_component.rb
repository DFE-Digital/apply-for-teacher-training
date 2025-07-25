module SupportInterface
  class CandidateAccountStatusComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :candidate_account_status
    delegate :candidate, :status, to: :candidate_account_status

    def initialize(candidate_account_status:)
      @candidate_account_status = candidate_account_status
    end

    def current_candidate_account_status
      content_tag :div, class: 'govuk-body' do
        if @candidate_account_status.unblocked?
          block_candidate_account_link
        else
          change_candidate_account_link
        end
      end
    end

    def block_candidate_account_link
      govuk_link_to 'Block account',
                    support_interface_edit_candidate_account_status_path(candidate)
    end

    def change_candidate_account_link
      html = content_tag :span, class: 'govuk-!-margin-right-2 app-link--warning' do
        SupportInterface::CandidateAccountStatusForm.human_attribute_name(status)
      end
      html << govuk_link_to('Change', support_interface_edit_candidate_account_status_path(candidate))
      html
    end
  end
end
