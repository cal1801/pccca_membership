class MembershipMailer < ApplicationMailer
  default from: 'joel@pccca.net'
  def error_email(members)
    @members = members
    mail(to: "callanfindeiss@gmail.com", subject: 'Welcome to My Awesome Site')
  end
end
