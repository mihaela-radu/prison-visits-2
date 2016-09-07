# Responsible for the relationship between identities and permissions retrieved
# from SSO, and the internal Users and Estates. Also for additional information
# returned from the SSO application which is stored in the user's session.
class SignonIdentity
  class InvalidSessionData < RuntimeError; end

  DIGITAL_ORG = 'digital.noms.moj'

  class << self
    def from_omniauth(omniauth_auth)
      info = omniauth_auth.fetch('info')
      user = find_or_create_authorized_user(info)
      return unless user

      additional_data = extract_additional_data(info)
      new(user, **additional_data)
    end

    def from_session_data(data)
      new(
        User.find(data.fetch('user_id')),
        full_name: data.fetch('full_name'),
        profile_url: data.fetch('profile_url'),
        logout_url: data.fetch('logout_url'),
        available_organisations: data.fetch('available_organisations'),
        current_organisation: data.fetch('current_organisation')
      )
    rescue KeyError
      raise InvalidSessionData
    end

  private

    def find_or_create_authorized_user(info)
      email = info.fetch('email')
      sso_orgs = info.fetch('permissions').map { |p| p.fetch('organisation') }

      unless sso_orgs.any?
        permissions = info.fetch('permissions')
        Rails.logger.info \
          "User #{email} has no valid permissions: #{permissions}"
        return nil
      end

      User.find_or_create_by!(email: email)
    end

    def extract_additional_data(info)
      links = info.fetch('links')
      sso_orgs = info.fetch('permissions').map { |p| p.fetch('organisation') }

      {
        full_name: full_name_from_additional_data(info),
        profile_url: links.fetch('profile'),
        logout_url: links.fetch('logout'),
        available_organisations: sso_orgs,
        current_organisation: default_current_org(sso_orgs)
      }
    end

    def full_name_from_additional_data(info)
      first_name = info.fetch('first_name')
      last_name = info.fetch('last_name')
      [first_name, last_name].reject(&:empty?).join(' ')
    end

    def default_current_org(sso_orgs)
      sso_orgs.reject { |org| org == SignonIdentity::DIGITAL_ORG }.first
    end
  end

  attr_reader :user, :full_name, :profile_url, :available_organisations,
    :current_organisation

  # rubocop:disable ParameterLists
  def initialize(user, full_name:, profile_url:, logout_url:,
    available_organisations:, current_organisation:)
    @user = user
    @full_name = full_name
    @profile_url = profile_url
    @logout_url = logout_url
    @available_organisations = available_organisations
    @current_organisation = current_organisation
  end
  # rubocop:enable ParameterLists

  def logout_url(redirect_to: nil)
    url = URI.parse(@logout_url)
    url.query = { redirect_to: redirect_to }.to_query if redirect_to
    url.to_s
  end

  # Export SSO data for storing in session between requests
  def to_session
    {
      'full_name' => @full_name,
      'user_id' => @user.id,
      'profile_url' => @profile_url,
      'logout_url' => @logout_url,
      'available_organisations' => @available_organisations,
      'current_organisation' => @current_organisation
    }
  end

  def change_current_organisation(sso_org)
    @current_organisation = sso_org
  end
end
