require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:ahmed)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface

  test "should paginate microposts" do
    get root_path
    assert_select 'div.pagination'
  end

  test "should show errors but not create micropost on invalid submission" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
  end

  test "should create a micropost on valid submission" do
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "should have micropost delete links on own profile page" do
    get users_path(@user)
    assert_select 'a', text: 'delete'
  end

  test "should be able to delete own micropost" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "should not have delete links on other user's profile page" do
    get user_path(users(:hacker))
    assert_select 'a', { text: 'delete', count: 0 }
  end

  test "should have a file field for image upload" do
    get root_path
    assert_select 'input[type="file"]'
  end

  test "should show image upload on valid submission" do
    content = "This micropost really ties the room together"
    image = fixture_file_upload('test/fixtures/images/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, image: image } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

end
