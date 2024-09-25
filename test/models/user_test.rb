require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "   "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end


  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
        assert_not @user.authenticated?(:remember, "")
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    ahmed = users(:ahmed)
    hacker  = users(:hacker)
    assert_not ahmed.following?(hacker)
    ahmed.follow(hacker)
    assert ahmed.following?(hacker)
    assert hacker.followers.include?(ahmed)
    ahmed.unfollow(hacker)
    assert_not ahmed.following?(hacker)
    # Users can't follow themselves.
    ahmed.follow(ahmed)
    assert_not ahmed.following?(ahmed)
  end


  test "feed should have the right posts" do
    ahmed   = users(:ahmed)
    hacker  = users(:hacker)
    lana    = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert ahmed.feed.include?(post_following)
    end
    # Self-posts for user with followers
    ahmed.microposts.each do |post_self|
      assert ahmed.feed.include?(post_self)
    end
    # Posts from non-followed user
    hacker.microposts.each do |post_unfollowed|
      assert_not ahmed.feed.include?(post_unfollowed)
    end
  end
end
