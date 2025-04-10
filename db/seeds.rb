# db/seeds.rb

# Create an admin user
admin_email = "imranaalam@gmail.com"
admin_password = "1234" # Change this!

unless User.exists?(email: admin_email)
  User.create!(
    name: "Admin User",
    email: admin_email,
    password: admin_password,
    password_confirmation: admin_password,
    role: :admin, # Assign the admin role
    verified: true # Optional: Mark as verified immediately
  )
  puts "Admin user created: #{admin_email}"
else
  puts "Admin user already exists: #{admin_email}"
end

# You can add member users too if needed
# ...
