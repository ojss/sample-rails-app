require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:ojas)
    @other = users(:evie)
    log_in_as(@user)
  end

  test "Following page" do
    get following_user_path(@user)
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select 'a[href=?]', user_path(user)
    end
  end

  test "Followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select 'a[href=?]', user_path(user)
    end
  end

  test "should follow a user non AJAX manner" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, followed_id: @other.id
    end
  end

  test "Should follow another user, AJAXy way" do
    assert_difference '@user.following.count', 1 do
      xhr :post, relationships_path, followed_id: @other.id
    end
  end

  test "should unfollow a user standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)

    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "Should unfollow another user, AJAXy way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)

    assert_difference '@user.following.count', -1 do
      xhr :delete, relationship_path(relationship)
    end
  end

  test "feed should have the right posts" do
    ojas = users(:ojas)
    evie = users(:evie)
    jacob = users(:jacob)

    # Posts from followed user
    evie.microposts.each do |post|
      assert jacob.feed.include?(post)
    end

    # Posts from self
    jacob.microposts.each do |post|
      assert jacob.feed.include?(post)
    end

    #   posts from unfollowed must not appear
    ojas.microposts.each do |post|
      assert_not jacob.feed.include?(post)
    end
  end
end
