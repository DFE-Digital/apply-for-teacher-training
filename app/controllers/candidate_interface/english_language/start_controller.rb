module CandidateInterface
  module EnglishLanguage
    class StartController < CandidateInterfaceController
      def new
        render_404 unless FeatureFlag.active?(:efl_section)
      end
    end
  end
end
