# This is the telegram bot script
#use the data of your actual bot 
#!/bin/bash
#Telegram bot
TOKEN="Your token in here"
#BOT_USERNAME= "@Your_bot"
CHAT_ID="Your_id"

  tg_send () {
  local msg="$1"
  curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    -d "text=${msg}" \
    -d "disable_web_page_preview=true"
}
