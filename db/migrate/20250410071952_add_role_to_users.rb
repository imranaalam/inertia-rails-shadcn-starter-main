# db/migrate/YYYYMMDDHHMMSS_add_role_to_users.rb
class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    # Add the column, ensure it's not null, and set a default value
    # Defaulting to 0 corresponds to the :member role in the enum
    add_column :users, :role, :integer, null: false, default: 0
    # Optional: Add an index if you frequently query by role
    # add_index :users, :role
  end
end
