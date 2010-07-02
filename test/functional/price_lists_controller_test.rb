require 'test_helper'

class PriceListsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:price_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create price_list" do
    assert_difference('PriceList.count') do
      post :create, :price_list => { }
    end

    assert_redirected_to price_list_path(assigns(:price_list))
  end

  test "should show price_list" do
    get :show, :id => price_lists(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => price_lists(:one).to_param
    assert_response :success
  end

  test "should update price_list" do
    put :update, :id => price_lists(:one).to_param, :price_list => { }
    assert_redirected_to price_list_path(assigns(:price_list))
  end

  test "should destroy price_list" do
    assert_difference('PriceList.count', -1) do
      delete :destroy, :id => price_lists(:one).to_param
    end

    assert_redirected_to price_lists_path
  end
end
