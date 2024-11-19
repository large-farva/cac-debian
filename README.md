# CAC Setup Script for Debian-Based Distros

## Overview

This script automates the setup of a CAC (Common Access Card) card on Debian-based Linux distributions. It ensures that all necessary dependencies are installed, configures the environment, and sets up browser integration for CAC functionality. This script is specifically designed for users working with US government CACs, and it provides compatibility with both Firefox and Chromium-based browsers.

## Features

- Removes conflicting packages that may interfere with CAC operation.
- Installs and configures OpenSC, pcsc-tools, and other required dependencies.
- Configures browsers to use CAC certificates for secure access.
- Downloads and installs the latest DoD certificates.

## Prerequisites

- A Debian-based Linux distribution (e.g., Debian, Ubuntu, PopOS!).
- Root or sudo access to install and configure packages.
- An integragted or USB smart card reader.

## Usage

1. **Clone the Repository**
  
  ```bash
  git clone https://github.com/large-farva/cac-debian.git
  cd cac-debian
  ```
  
2. **Make the Script Executable**
  
  ```bash
  chmod +x cac-debian.sh
  ```
  
3. **Run the Script**
  
  ```bash
  sudo ./cac-debian.sh
  ```
  

The script will guide you through each step, displaying messages about what is currently being configured or installed.

## Script Steps

1. **Remove Conflicting Packages**: Uninstalls packages like `cackey` and `coolkey` that conflict with OpenSC.
2. **Update System and Install Dependencies**: Updates your package list and installs necessary dependencies.
3. **Restart pcscd Daemon**: Ensures the smart card daemon is running properly.
4. **Unload Kernel Modules**: Optional troubleshooting step to unload conflicting NFC modules.
5. **Configure OpenSC**: Adds required configurations to `/etc/opensc/opensc.conf`.
6. **Download DoD Certificates**: Downloads the latest DoD certificates required for authentication.
7. **Load PKCS11 Module in Firefox**: Adds the OpenSC PKCS11 module to Firefox.
8. **Import DoD Certificates to Firefox**: Imports downloaded certificates to Firefox.
9. **Add CAC Module to Chromium-Based Browsers**: Configures Chromium to use the OpenSC PKCS11 module.
10. **Import DoD Certificates to Chromium-Based Browsers**: Adds certificates to the NSS DB for use with Chromium-based browsers.
11. **Import DoD Certificates to System Certificate Store**: Installs DoD certificates into the system-wide certificate store.
12. **Update Certificate Store**: Updates the certificate store to recognize newly imported certificates.

## Troubleshooting

- **PCSC Daemon Issues**: If the script fails to detect the card, ensure the `pcscd` service is running:
  
  ```bash
  sudo systemctl status pcscd
  ```
  
  Restart the service if necessary:
  
  ```bash
  sudo systemctl restart pcscd
  ```
  
- **Browser Not Recognizing CAC**: Verify the security module is loaded in Firefox or Chromium, and that the DoD certificates are properly imported.

## Notes

- This script is optimized for CAC cards but may work with PIV cards as well.

## Disclaimer

This script is provided "as is" without warranty of any kind. Use it at your own risk. Ensure you have backups and understand the changes being made to your system before executing the script.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributions

Feel free to submit pull requests or open issues if you encounter any problems or have suggestions for improvement. Any and all feedback is welcomed!

## Author

- Sebastian (GitHub: [large-farva](https://github.com/large-farva))
