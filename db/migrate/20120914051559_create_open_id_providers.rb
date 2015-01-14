class CreateOpenIdProviders < ActiveRecord::Migration
  def change
    create_table :open_id_providers do |t|
      t.string :issuer, null: false
      t.string :identifier, :secret, :redirect_uri
      t.datetime :expires_at
      t.timestamps
    end
  end
end
