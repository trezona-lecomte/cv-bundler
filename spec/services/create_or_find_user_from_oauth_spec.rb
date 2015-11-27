require "rails_helper"

RSpec.describe CreateOrFindUserFromOauth, type: :service do
  let(:service) { CreateOrFindUserFromOauth.new(auth_hash) }
  let(:auth_hash) { OmniAuth.config.mock_auth[:twitter] }

  context "when the user doesn't yet exist" do
    it "creates a new user" do
      expect { service.call }.to change { User.count }.by(1)
    end
  end

  context "when the user already exists" do
    context "when the user's attributes remain the same" do
      before do
        2.times { CreateOrFindUserFromOauth.new(auth_hash).call }
      end

      it "returns the existing user instead of creating one" do
        expect(User.count).to eq(1)
      end
    end

    context "when the user's attributes change" do
      let(:new_email) { Faker::Internet.email }

      before do
        CreateOrFindUserFromOauth.new(auth_hash).call
        auth_hash["info"]["email"] = new_email
        CreateOrFindUserFromOauth.new(auth_hash).call
      end

      it "updates the existing user's attributes" do
        expect(User.last.email).to eq(new_email)
      end
    end
  end
end