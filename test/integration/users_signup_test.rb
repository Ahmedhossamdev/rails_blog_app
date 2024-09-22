require "test_helper"


class UserSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:ahmed)
  end
end


class UsersSignupTest < UserSignup
  test "invalid signup information with account activation" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
    end
    assert 1, ActionMailer::Base.deliveries.size

  end


  test "valid signup information" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    # assert_template "users/show"
    # assert is_logged_in?
    assert_not flash.empty?
  end
end

# class AccountActivation < UserSignup
#   def setup
#     super
#     @user = users(:ahmed)
#   end
# end

class AccountActivationTest < UserSignup
  def setup
    super
    @user = users(:ahmed)
    post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password" } }

    @user = assigns(:user)
  end

  test "should not be activated" do
    assert_not @user.activated?
  end

  test "should not be able to login before account activation" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "should not be able to login with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  test "should not be able to login with invalid email" do
    get edit_account_activation_path(@user.activation_token, email: "invalid email")
    assert_not is_logged_in?
  end

  test "should be able to login with valid activation token" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
  end
end
# Compare this snippet from test/integration/users_signup_test.rb:
# require "test_helper"
#
# class UserSignup < ActionDispatch::IntegrationTest
#   def setup
#     ActionMailer::Base.deliveries.clear
#     @user = users(:ahmed)
#   end
# end
#
#
# class UsersSignup
