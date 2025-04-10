# app/models/ability.rb
# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md

    # Guest user (not logged in)
    user ||= User.new # guest user (not logged in) -> assign a default role or check for nil later

    if user.admin?
      can :manage, :all # Admins can do anything
    elsif user.member?
      # Members can read the dashboard
      can :read, :dashboard

      # Members can manage their own profile, email, password, sessions
      # Note: Settings controllers often load @user = Current.user directly,
      # so checking `can :manage, user` might be simpler.
      # Or use hash conditions for clarity:
      can :manage, User, id: user.id # Can manage their own user record (profile, password, delete)
      can :manage, Session, user_id: user.id # Can manage their own sessions

      # Allow reading/updating own settings (alternative approach if Settings controllers use specific resources)
      # can [:show, :update], Settings::Profile, user_id: user.id # Assuming a Profile model existed
      # can [:show, :update], Settings::Email, user_id: user.id
      # can [:show, :update], Settings::Password, user_id: user.id
      # can :index, Settings::Session, user_id: user.id

      # Allow specific identity actions if tied to the current user
      # can :create, Identity::EmailVerification # Resend verification for self
      # Password reset and initial verification are handled separately (often skipped)

    else
      # Guest permissions (e.g., read public pages)
      # CanCanCan is often not used for guest access, as `skip_before_action :authenticate` handles it.
      # If you had public resources, you might define them here:
      # can :read, PublicArticle
    end
  end
end
