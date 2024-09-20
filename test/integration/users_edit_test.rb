require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:ahmed)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    patch user_path(@user), params: { user: {
      name: "",
      email: "foo@invalid",
      password: "foo",
      password_confirmation: "bar"
    } }

    assert_template "users/edit"
  end


  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    assert_not_nil session[:forwarding_url]
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    patch user_path(@user), params: { user: {
      name: "Test",
      email: "2Mqz7@example.com",
      password: "password",
      password_confirmation: "password"
    } }

    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, @user.name
    assert_equal @user.email, @user.email
  end
end
