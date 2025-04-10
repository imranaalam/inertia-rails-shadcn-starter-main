# app/models/user.rb
# frozen_string_literal: true

class User < ApplicationRecord
  # Define roles using an enum
  # :member is the default (index 0)
  enum :role, {member: 0, admin: 1} # <--- Corrected syntax
  attribute :role, :integer # <--- Add this

  has_secure_password

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, allow_nil: true, length: {minimum: 12}
  # Optional: Add validation for role if needed, though enum handles basic validation
  # validates :role, presence: true

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  # Ensure new users get a default role
  after_initialize :set_default_role, if: :new_record?

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  private

  def set_default_role
    self.role ||= :member
  end
end
