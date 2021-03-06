module SessionsHelper
  # Logs in the given user, sets up the sessions and store a cookie
  def log_in(user)
    session[:user_id]=user.id
  end

  def remember(user)
    #   Remembers a user in a persistent system
    user.remember
    # cookies[:user_id] = {value: user.id, expires: 20.years.from_now.utc}
    # equivalently:
    cookies.permanent.signed[:user_id]=user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user?(user)
    @user == current_user
  end

  # returns the current logged in user(if any)
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      # raise
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # forgets a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def store_location
    #   Stores the URL that is trying to be accessed, applies to protected paths like edit and update
    session[:forwarding_url] = request.url if request.get?
  end

  def redirect_back_or(default)
    #   Redirects to stored location or to a default if stored location doesn't exist
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end
