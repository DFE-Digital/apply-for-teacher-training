require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'apply_service_is_now_open', time: mid_cycle do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.apply_service_is_now_open(provider_user) }

    it_behaves_like(
      'a mail with subject and content',
      'Candidates can now apply - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => "The #{CycleTimetable.current_year} to #{CycleTimetable.next_year} recruitment cycle has started. Candidates can now apply to your courses.",
      'link to applications' => 'http://localhost:3000/provider/applications',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end
end
