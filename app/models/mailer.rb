class Mailer < ActionMailer::Base
  def reset_password_message(member, url)
    recipients member.email
    from       SYSTEM_EMAIL_ADDRESS
    subject    "[Camping-gas] Confirm password reset"
    body       :member => member, :url => url
  end
end