#!/bin/bash
function mas_install() {
  app=$(mas search "$1" | awk '{print $1}' | head -n 1)
  if [ "a$app" != "a" ]; then
    mas install $app
  fi
}
mas_install "feedly. Read more, know more."
mas_install "SwordSoft Screenink"
mas_install "Cloud Outliner 2 Pro: Outline your Ideas & Plans"
mas_install "Fantastical 2 - Calendar and Reminders"
mas_install "LastPass: Password Manager and Secure Vault"
mas_install "Slack"
mas_install "Disk Inspector"
mas_install "OneDrive"
mas_install "iA Writer"
mas_install "Blackmagic Disk Speed Test"
mas_install "Microsoft Remote Desktop"
mas_install "Tweetbot for Twitter"
mas_install "Things"
mas_install "Pocket"
mas_install "Capster"
mas_install "AudioNote 2 - Notepad and Voice Recorder"
mas_install "AudioNote - Notepad and Voice Recorder"
mas_install "Disk Expert - Space Usage Analyzer & Cleanup Utility"
mas_install "HardwareGrowler"
mas_install "Skitch - Snap. Mark up. Share."
mas_install "Twitter"
mas_install "WhatsApp Desktop"
mas_install "Todoist: To Do List | Task List"
mas_install "Screens VNC - Remote Access To Your Computer"

