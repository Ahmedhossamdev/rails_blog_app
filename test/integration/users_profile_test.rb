require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  def setup
    @user = users(:ahmed)
  end

  test "profile display" do
    get user_path(users(:ahmed))
    assert_template "users/show"
    assert_select "title", full_title(users(:ahmed).name)
    assert_select "h1", text: users(:ahmed).name
    assert_select "h1>img.gravatar"
    assert_match users(:ahmed).microposts.count.to_s, response.body
    assert_select "div.pagination"
    users(:ahmed).microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
