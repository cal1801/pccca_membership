class MembershipMailer < ApplicationMailer
  default from: 'membership@pccca.net'
  def error_email(members)
    @members = members
    mail(
      :subject => 'Error with PayPal for Membership',
      :to  => 'callanfindeiss@gmail.com',
      :from => 'membership@pccca.net',
      :track_opens => 'true')
  end

  def success_email(members, organization)
    @members = members
    @organization = organization
    mail(
      :subject => 'New Membership Registered',
      :to  => 'joel@pccca.net',
      :from => 'membership@pccca.net',
      :track_opens => 'true')
  end

  def provide_benefit_email(organization)
    @organization = organization
    mail(
      :subject => 'Organization Agreed to Membership Benefit',
      :to  => 'joel@pccca.net',
      :from => 'membership@pccca.net',
      :track_opens => 'true')
  end
end
