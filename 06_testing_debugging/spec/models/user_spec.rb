require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:articles).dependent(:destroy) }
    it { should have_many(:comments).dependent(:nullify) }
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:groups).through(:memberships) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "default role" do
    it "sets member role by default" do
      user = build(:user)
      expect(user.role).to eq("member")
    end
  end

  describe "#admin?" do
    it "returns true for admin users" do
      user = build(:user, :admin)
      expect(user.admin?).to be true
    end

    it "returns false for member users" do
      user = build(:user)
      expect(user.admin?).to be false
    end
  end

  describe "#editor_or_above?" do
    it "returns true for admin users" do
      expect(build(:user, :admin).editor_or_above?).to be true
    end

    it "returns true for editor users" do
      expect(build(:user, :editor).editor_or_above?).to be true
    end

    it "returns false for member users" do
      expect(build(:user).editor_or_above?).to be false
    end
  end

  describe "#display_name" do
    it "returns name when present" do
      user = build(:user, name: "Taro")
      expect(user.display_name).to eq("Taro")
    end

    it "returns email prefix when name is blank" do
      user = build(:user, name: "", email: "taro@example.com")
      # Devise validatable requires name presence, so we skip validation
      user.name = nil
      expect(user.display_name).to eq("taro")
    end
  end
end
