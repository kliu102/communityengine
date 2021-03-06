class AuthorizationsController < BaseController
  before_action :login_required, :only => [:destroy]

  def create
    omniauth = request.env['omniauth.auth'] #this is where you get all the data from your provider through omniauth
    provider_name = omniauth['provider'].to_s.capitalize

    @auth = Authorization.find_or_create_from_hash(omniauth, current_user)

    if logged_in?
      flash[:notice] = t('authorizations.create.success_existing_user', :provider => provider_name)
    elsif @auth.valid?
      flash[:notice] = t('authorizations.create.success_message', :provider => provider_name)
      user_session = UserSession.create(@auth.user, true)
      self.current_user = user_session.user
    end

    if logged_in?
      redirect_to request.env['omniauth.origin'] || user_path(current_user)
    else
      flash[:notice] = @auth.user.errors.full_messages.to_sentence
      redirect_to login_path
    end
  end

  def failure
    flash[:notice] = t('authorizations.failure.notice')
    redirect_to home_url
  end

  def destroy
    @authorization = current_user.authorizations.find(params[:id])

    if @authorization.destroy
      flash[:notice] = t('authorizations.destroy.notice', :provider => @authorization.provider.to_s.capitalize)
    else
      flash[:notice] = @authorization.errors.full_messages.to_sentence
    end

    redirect_to edit_account_user_path
  end
end
