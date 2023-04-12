require "test_helper"

class LeaseControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get lease_index_url
    assert_response :success
  end

  test "should get start" do
    get lease_start_url
    assert_response :success
  end

  test "should get download" do
    get lease_download_url
    assert_response :success
  end
end
