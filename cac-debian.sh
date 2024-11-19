#!/bin/bash

# This script automates the setup of a CAC/PIV card on Debian based distros!

# Step 1: Remove conflicting packages
echo "Step 1: Removing conflicting packages..."
sudo apt remove cackey coolkey libckyapplet1 libckyapplet1-dev -y && sudo apt purge -y

# Step 2: Update and Install Dependencies
echo "Step 2: Updating system and installing dependencies..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install pcsc-tools libccid libpcsc-perl libpcsclite1 pcscd opensc opensc-pkcs11 vsmartcard-vpcd libnss3-tools -y

# Step 3: Restart and Check pcscd Daemon
echo "Step 3: Restarting pcscd daemon..."
sudo systemctl restart pcscd.socket && sudo systemctl restart pcscd.service

echo "Checking pcscd daemon status..."
sudo systemctl status pcscd.s*

# Step 4: Unload conflicting kernel modules (optional troubleshooting step)
echo "Step 4: Unloading conflicting kernel modules (optional)..."
modprobe -r pn533 nfc

# Step 5: Configure OpenSC
echo "Step 5: Configuring OpenSC..."
if ! grep -q 'force_card_driver' /etc/opensc/opensc.conf; then
    echo -e '\n# Adding CAC card drivers to OpenSC configuration\ncard_drivers = cac\nforce_card_driver = cac' | sudo tee -a /etc/opensc/opensc.conf
fi

# Step 6: Download DoD Certificates
echo "Step 6: Downloading DoD certificates..."
wget https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/certificates_pkcs7_DoD.zip && unzip certificates_pkcs7_DoD.zip

# Step 7: Load the PKCS11 Module in Firefox Automatically
echo "Step 7: Loading PKCS11 module in Firefox..."
pkcs11-register

# Step 8: Import DoD Certificates to Firefox
echo "Step 8: Importing DoD certificates to Firefox..."
for cert_file in Certificates_PKCS7_v5.7_DoD*.p7b; do
    echo "Importing $cert_file to Firefox..."
    certutil -d sql:$HOME/.mozilla/firefox/*.default-release -A -t "C," -n "$cert_file" -i "$cert_file"
done

# Step 9: Add the CAC Module to NSS DB for Chromium-based Browsers
echo "Step 9: Adding CAC module to NSS DB for Chromium-based browsers..."
modutil -dbdir sql:$HOME/.pki/nssdb/ -add "OpenSC smartcard framework" -libfile /usr/lib/onepin-opensc-pkcs11.so

# Step 10: Import DoD Certificates to NSS DB for Chromium-based Browsers
echo "Step 10: Importing DoD certificates to NSS DB for Chromium-based browsers..."
for n in *.p7b; do
    echo "Importing $n to NSS DB..."
    certutil -d sql:$HOME/.pki/nssdb -A -t TC -n $n -i $n
done

# Step 11: Install VMware Horizon Client (Example - Replace with latest version)
echo "Step 11: Installing VMware Horizon Client..."
chmod +x VMware-Horizon-Client-*.x64.bundle
sudo ./VMware-Horizon-Client-*.x64.bundle

# Step 12: Setup CAC Login for VMware Horizon
echo "Step 12: Setting up CAC login for VMware Horizon..."
sudo ln -s /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so /usr/lib/vmware/view/pkcs11/libopenscpkcs11.so

# Step 13: Import DoD Certificates to System Certificate Store
echo "Step 13: Importing DoD certificates to system certificate store..."
openssl pkcs7 -print_certs -in Certificates_PKCS7_v5.9_DoD.pem.p7b -out dod_bundle.pem

echo "Splitting the PEM file into individual CRT files..."
awk '
  split_after == 1 {n++; split_after=0}
  /-----END CERTIFICATE-----/ {split_after=1}
  {print > "cert" n ".crt"}' < dod_bundle.pem

echo "Creating directory for DoD certificates and copying CRT files..."
sudo mkdir -p /usr/local/share/ca-certificates/dod/
sudo cp *.crt /usr/local/share/ca-certificates/dod/

# Step 14: Update Certificate Store
echo "Updating certificate store..."
sudo update-ca-certificates

echo "Setup Complete! You are now fully CAC enabled on your Linux system."
