module TestHelpers
  module SignUp
    def fill_in_sign_up
      fill_in t("authentication.sign_up.email_address.label"), with: "april@pawnee.com"
      click_on t("authentication.sign_up.button")
    end
  end
end
