class AddColumnUsers < ActiveRecord::Migration
  def change
    add_column :users, :lifelog_oauth_token, :string
  end
end
