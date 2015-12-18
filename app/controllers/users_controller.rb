class UsersController < ApplicationController

  before_action :logged_in_user, only: [:edit, :update, :destroy, :index]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    # debugger
  end

  def edit
    @user = User.find(params[:id])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      #   handle successful edit
      flash[:success] = "Profile Updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      #handle a successful save
      log_in @user
      flash[:success] = "Welcome the the App!"
      redirect_to user_url(@user)
    else
      render 'new'
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Before filters
  private
  # Confirms a logged in user
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in"
      redirect_to login_url
    end
  end

  private
  def correct_user
    #   Confirms the correct user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  private
  def admin_user
  #   Confirms that the user is an admin
    redirect_to(root_url) unless current_user.admin?
  end
end
