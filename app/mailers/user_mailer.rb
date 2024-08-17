class UserMailer < ApplicationMailer
  def welcome_email
    @name = params[:name]
    email_verification_token = JWT.encode({ user_id: params[:user_id] }, ENV['AUTH_SECRET_KEY'])

    @url = "http://localhost:3000/users/confirm_email?token=#{email_verification_token}"
    mail(to: params[:email], subject: 'Welcome to Quora!!')
  end

  def ban_email
    @name =  params[:name]
    mail(to: params[:email], subject: 'Banned from Quora!!', content_type: 'text/html',
         body: '<html><strong>Hello there</strong></html>')
  end
end
