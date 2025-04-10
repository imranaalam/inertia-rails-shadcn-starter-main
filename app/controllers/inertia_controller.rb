# frozen_string_literal: true

class InertiaController < ApplicationController
  inertia_config default_render: true
  inertia_share flash: -> { flash.to_hash },
      auth: -> {
        if Current.user
          {
            user: Current.user.as_json(only: %i[id name email verified role created_at updated_at]), # Add :role
            session: Current.session&.as_json(only: %i[id]) # Use safe navigation for session
          }
        else
          {user: nil, session: nil} # Ensure auth object exists even when logged out
        end
      }

  private

  def inertia_errors(model, full_messages: true)
    {
      errors: model.errors.to_hash(full_messages).transform_values(&:to_sentence)
    }
  end
end
