class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy

  attr_accessor :remember_token
  attr_accessor :activation_token
  attr_accessor :reset_token

  before_save :downcase
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: 60}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  has_secure_password

  validates :password, presence: true, length: {minimum: 6}


  # Returns hash digest of the given string using the bcrypt hashing algorithm
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  #   Returns a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers the user in the database, for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  #   Forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account
  def activate
    self.update_attribute(:activated, true)
    self.update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_mail
    UserMailer.account_activation(self).deliver_now
  end

  # Sets password reset digest, attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Checks if the password reset token has expired, returns true if expired
  def password_reset_expired?
    self.reset_sent_at < 2.hours.ago
  end

  # Defines a proto-feed
  # See "following users" for full implementation
  def feed
    Micropost.where("user_id = ?", id)
  end

  private
  # Converts an email into all lower-case
  def downcase
    self.email=email.downcase
  end

  private
  def create_activation_digest
    #   Creates and assigns activation token and digest
    self.activation_token = User.new_token
    self.activation_digest= User.digest(self.activation_token)
  end
end
