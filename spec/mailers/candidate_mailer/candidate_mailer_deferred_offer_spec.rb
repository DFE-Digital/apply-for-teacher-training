require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.deferred_offer' do
    let(:email) { described_class.deferred_offer(application_choices.first) }
    let(:application_choices) { [build_stubbed(:application_choice, :offered, offer:, course_option:)] }
    let(:offer) { build_stubbed(:offer, conditions: []) }

    before do
      magic_link_stubbing(application_form.candidate)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Your offer has been deferred',
      'heading' => 'Dear Fred',
      'name and code for course' => 'Mathematics (M101)',
      'name of provider' => 'Arithmetic College',
      'year of new course' => "until the next academic year (#{next_timetable.academic_year_range_name})",
    )
  end
end
