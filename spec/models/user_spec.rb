require 'rails_helper'

RSpec.describe User, type: :model do
  describe User do
    it "is valid with a name, email, and password" do
      user = User.new(
        name: "mr.spec",
        email: "mr@spec.com",
        password: "password",
      )
      expect(user).to be_valid
    end
    it "is invalid without a name" do
      user = User.new(
        name: "mr.spec",
        email: "mr@spec.com",
        password: "password",
      )
      expect(user).to be_valid
    end
    it "is invalid without an email address" do
      user = User.new(
        name: "mr.spec",
        email: "mr@spec.com",
        password: "password",
      )
      expect(user).to be_valid
    end
    it "is invalid with a duplicate email address" do
      user = User.new(
        name: "mr.spec",
        email: "mr@spec.com",
        password: "password",
      )
      expect(user).to be_valid
    end
    it "returns a user's name as a string" do
      user = User.new(
        name: "mr.spec",
        email: "mr@spec.com",
        password: "password",
      )
      expect(user).to be_valid
    end
    it "is invalid without a name" do
      user = User.new(name: nil)
      user.valid?
      expect(user.errors[:name]).to include("can't be blank")
    end
    it "is invalid with a duplicate email adress" do
      User.create(
        name: "sample1",
        email: 'sample@sample.com',
        password: 'password'
      )
      user = User.new(
        name: 'sample2',
        email: 'sample@sample.com',
        password: 'password'
      )
      user.valid?
      expect(user.errors[:email]).to include('has already been taken')
    end

    it "has a valid factory" do
      expect(FactoryBot.build(:user)).to be_valid
    end
  end
end
