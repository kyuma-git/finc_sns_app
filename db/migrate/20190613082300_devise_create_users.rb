# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      ## Database authenticatable
      # DBに保存するパスワードの暗号化(必須)
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      # メール通知を受け取るならtrue
      t.boolean :receive_notification, default: true
      # adminユーザならtrue
      t.boolean :is_admin, default: false

      ## Recoverable
      # パスワードリセット
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      # クッキーにログイン情報を保持
      t.datetime :remember_created_at

      ## Trackable
      # サインイン回数・時刻・IPアドレスを保存できるが、今回は使わない
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # 登録時にメールを送信して確認できるが、今回は使わない
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # 一定回数ログインに失敗した際のアカウントロック
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
