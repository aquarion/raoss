tell application "PDFpen"
  open theFile as alias
  tell document 1
        ocr
        repeat while performing ocr
            delay 1
        end repeat
     delay 1
        close with saving
  end tell
end tell