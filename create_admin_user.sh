#!/bin/sh

###############################################################################
# create_admin_user.sh
#
# This script:
#   1) Mounts the primary Data volume in macOS Recovery (if necessary).
#   2) Creates a new admin user account with a specified username & password.
#   3) Bypasses macOS Setup Assistant by creating the .AppleSetupDone file.
#
# NOTE: Adjust the "newUser", "fullName", and "userPass" variables below to
# match your desired username, full name, and password.
###############################################################################

# 1) Customize these variables before running:
newUser="test"                # Desired short username (no spaces)
fullName="test"   # Full name for the user
userPass="1234"        # Password for the user

# 2) Attempt to mount the Data volume, if not already mounted:
#    (We try both “Macintosh HD - Data” and “Data” in case your volume is named differently.)
diskutil mount "Macintosh HD - Data" 2>/dev/null || diskutil mount Data 2>/dev/null

# Path to the local DS node on the mounted volume
DS_PATH="/Volumes/Macintosh HD - Data/private/var/db/dslocal/nodes/Default"

# 3) Create the user:
dscl -f "$DS_PATH" localhost -create "/Local/Default/Users/$newUser"
dscl -f "$DS_PATH" localhost -create "/Local/Default/Users/$newUser" UserShell "/bin/zsh"
dscl -f "$DS_PATH" localhost -create "/Local/Default/Users/$newUser" RealName "$fullName"
dscl -f "$DS_PATH" localhost -create "/Local/Default/Users/$newUser" UniqueID "502"
dscl -f "$DS_PATH" localhost -create "/Local/Default/Users/$newUser" PrimaryGroupID "20"
dscl -f "$DS_PATH" localhost -create "/Local/Default/Users/$newUser" NFSHomeDirectory "/Users/$newUser"

# 4) Create a home directory for the new user (optional but recommended)
mkdir "/Volumes/Macintosh HD - Data/Users/$newUser"
chown -R $newUser:staff "/Volumes/Macintosh HD - Data/Users/$newUser"

# 5) Set the user’s password
dscl -f "$DS_PATH" localhost -passwd "/Local/Default/Users/$newUser" "$userPass"

# 6) Give the user admin rights by adding them to the 'admin' group
dscl -f "$DS_PATH" localhost -append "/Local/Default/Groups/admin" GroupMembership "$newUser"

# 7) Create .AppleSetupDone so macOS will skip Setup Assistant on reboot
touch "/Volumes/Macintosh HD - Data/private/var/db/.AppleSetupDone"

###############################################################################
# Done! Once this script is finished, just run 'reboot' in Recovery.
# The Mac will then boot straight to the login window with your new admin user.
###############################################################################

echo \"[INFO] New admin user '$newUser' created. Setup Assistant will be skipped on next boot.\"
echo \"[INFO] Type 'reboot' to restart.\"
