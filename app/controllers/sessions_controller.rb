class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      #   login the user and redirect to profile page
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)

      redirect_back_or user
    else
      #   render new and show errors
      flash.now[:danger] = 'Invalid Email/Password'
      render 'new'
    end

  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
