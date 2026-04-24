module VendorAPI
  module Changes
    module V18
      class EnglishAsAForeignLanguageCandidateResponse < VersionChange
        description 'Does the candidate intend to take an English as a foreign language assessment?'

        resource ApplicationPresenter, [ApplicationPresenter::EnglishAsAForeignLanguageCandidateResponse]
      end
    end
  end
end
