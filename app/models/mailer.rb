class Mailer < ActionMailer::Base
  def reset_password_message(member, url)
    recipients member.email
    from       SYSTEM_EMAIL_ADDRESS
    subject    "[PaperCups] Confirm password reset"
    body       :member => member, :url => url
  end
end