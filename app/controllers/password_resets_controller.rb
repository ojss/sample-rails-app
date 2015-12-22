class PasswordResetsController < ApplicationController

  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit

  end

  def update
    if (params[:user][:password].blank? && params[:user][:password_confirmation].blank?)
      flash.now[:danger] = "Password/confirmation cannot be blank"
      render 'edit'

    elsif @user.update_attributes(user_params)
      flash[:success] = "Password has been updated"
      log_in @user
      redirect_to user_url(@user)
    else
      render 'edit'
    end
  end


  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Before actions
  private
  def get_user
    @user = User.find_by(email: params[:email])

  end

  #   confirms valid_user
  private
  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  # Checks if the reset token has expired
  private
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset window has expired"
      redirect_to new_password_reset_url
    end
  end
end
