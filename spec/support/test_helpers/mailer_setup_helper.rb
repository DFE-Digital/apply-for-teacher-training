module TestHelpers
  module MailerSetupHelper
    def magic_link_stubbing(candidate)
      allow(candidate).to receive(:create_magic_link_token!).and_return('raw_token')
    end

    def email_log_interceptor_stubbing
      allow(EmailLogInterceptor).to receive(:generate_reference).and_return('fake-ref-123')
    end

    def course_option
      create(
        :course_option,
        course: create(
          :course,
          name: 'Mathematics',
          code: 'M101',
          provider: create(
            :provider,
            name: 'Arithmetic College',
          ),
        ),
      )
    end

    def application_form
      build(:application_form, first_name: 'Fred',
                               candidate:,
                               application_choices:)
    end

    def application_choices
      [build(:application_choice)]
    end

    def candidate
      create(:candidate)
    end
  end
end
