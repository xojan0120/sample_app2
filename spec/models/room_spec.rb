require 'rails_helper'

RSpec.describe Room, type: :model do
  it "有効な状態であること" do
    room = Room.new
    expect(room).to be_valid
  end
end
