require "rails_helper"

describe "A candidate signing up" do
  include TestHelpers::SignUp

  context "who successfully signs up" do
    before do
      visit "/"
      click_on t("application_form.begin_button")
      fill_in_sign_up
    end

    it "sees the check your email page" do
      expect(page).to have_content t("authentication.check_your_email")
    end

    context "receives an email with a valid magic link" do
      let(:sign_in_link) { current_email.find_css("a").first }

      before do
        open_email("april@pawnee.com")
      end

      it "does sign the user in" do
        sign_in_link.click
        expect(page).to have_content "april@pawnee.com"
      end

      it "does not sign the user in when the token expiration time has passed" do
        Timecop.travel(Time.now + 1.hour + 1.second) do
          sign_in_link.click

          expect(page).not_to have_content "april@pawnee.com"
        end
      end
    end
  end

  context "who tries to sign up twice" do
    it "sees the form error summary" do
      visit candidate_interface_sign_up_path
      fill_in_sign_up
      visit candidate_interface_sign_up_path
      fill_in_sign_up

      expect(page).to have_content "There is a problem"
    end
  end

  context "who clicks a link with an invalid token" do
    it "sees the start page" do
      visit candidate_interface_welcome_path(token: "meow")

      expect(page.current_url).to eq(candidate_interface_start_url)
    end
  end
end
