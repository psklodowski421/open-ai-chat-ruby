# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  chat_id    :bigint           not null
#  role       :string
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Message < ApplicationRecord
  belongs_to :chat
end
