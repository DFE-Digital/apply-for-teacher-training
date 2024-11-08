require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'find_service_is_now_open', time: mid_cycle do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.find_service_is_now_open(provider_user) }

    it_behaves_like(
      'a mail with subject and content',
      'Candidates can now find courses - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => "Candidates can now find your courses for the #{CycleTimetable.current_year} to #{CycleTimetable.next_year} recruitment cycle.",
      'Opening date paragraph' => "They’ll be able to apply on #{CycleTimetable.apply_opens.to_fs(:govuk_date)} at 9am.",
    )
  end
end
