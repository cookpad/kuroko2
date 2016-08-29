module SignInHelper
  def sign_in(user = create(:user))
    controller.instance_variable_set(:@_current_user, user)
  end
end
