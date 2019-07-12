# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  context "as an logged in user" do
    describe '#index' do
      before do
        @user = FactoryBot.create(:user)
      end
      it "response success" do
        sign_in @user
        get :index
        expect(response).to be_success
      end
    end
  end
  context "as an unlogged in user" do
    describe '#index' do
      it 'response success' do
        get :index
        expect(response).to be_success
      end
    end
  end
end
