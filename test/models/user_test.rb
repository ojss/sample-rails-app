require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name=" "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email=" "
    assert_not @user.valid?
  end

  test "name shoudn't be too long" do
    @user.name = "a" * 65
    assert_not @user.valid?
  end
  test "email shoudn't be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "should accept valid email address" do
    valid_addresses = %w[user@example.com user123@example.com USER@foo.COM A_US-ER@foo.bar.org
                          first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_addr|
      @user.email = valid_addr
      assert @user.valid?
    end
  end

  test "should reject these emails" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?
    end
  end

  test "email addresses for uniqueness" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be in lower case only" do
    mixed_case_email = "FoO@eXampLe.Com"
    @user.email= mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase!, @user.reload.email
  end
  test "password should have a minimum length" do
    @user.password_confirmation=@user.password = "a" * 5
    assert_not @user.valid?
  end
  test "authenticated? should return false for a user with nil digest" do
  assert_not @user.authenticated?(:remember,'')
  end
end
