rem pyinstaller --noconfirm --onefile --windowed  --icon=icon.ico --add-data "icon.ico;." PhoneNumberManager.py

pyinstaller --noconfirm --onefile --windowed --icon=icon.ico --add-data "icon.ico;." --exclude-module torch PhoneNumberManager.py
