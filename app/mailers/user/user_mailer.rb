class User::UserMailer < ApplicationMailer
  def confirmation_instructions(user, site)
    @user = user
    @site = site
    @site_host = site_host

    mail(
      from: from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: t('.subject', site_name: @site.name)
    )
  end

  def reset_password_instructions(user, site)
    @user = user
    @site = site
    @site_host = site_host

    mail(
      from: from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: t('.subject')
    )
  end

  def welcome(user, site)
    @user = user
    @site = site
    @site_url = root_url(host: @site.domain)
    @notifications_url = user_notifications_url(host: @site.domain)
    @site_host = site_host

    mail(
      from: from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: t('.subject')
    )
  end
end
