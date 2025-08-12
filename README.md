# Pyro-Porter

## Hi there! I'm **Arsham**, and welcome to **Pyro-Porter**!

a comprehensive toolkit developed for efficiently unpacking, modifying, and rebuilding ROMs using UKL and Pyro scripts.

This guide will walk you through setting everything up and using the tool effectively.

---

## 🚀 Getting Started

### 1. Clone the Repository in "home directory"

Open a terminal and run:

```bash
cd $HOME && git clone https://github.com/ArshamEbr/Rosemary-Porter.git && cd Rosemary-Porter
```
---

## 🛠 Preparing ROM Files

Note: Fastboot ROMs are not currently supported only use `Recovery` ROMs.

1.Download the stock recovery ROM for your target device.

2.Place the downloaded stock ROM ZIP file into the `stock` folder.

3.Place the ROM you intend to port into the `port` folder.


## 🔥 Running the Pyro Scripts

To patch and rebuild the ROM, run the following command:

```bash
chmod +x Ash.sh && sudo ./Ash.sh
```

Upon successful completion, your ported ROM will be generated inside the `output` folder.
your stock rom `firmware` files also extracted inside `output/fw` if you want to flash.

---

## 🎯 Additional Information

- Feel free to modify the scripts to your heart's content, All scripts are fully commented to facilitate customization.
- This version of UKL has been enhanced to support EROFS unpacking and repacking, as well as conversion from ext4 to EROFS. It can be used independently.
- Ensure you run scripts with `sudo` to avoid permission issues.
- Contributions, bug reports, and feature requests are welcome.
- For direct contact, find me on Telegram: @ArshamEbr.
- Everything will be cleaned except the `port`, `stock`, and `output` folders to preserve free space.
- This script is universal and compatible with all Xiaomi phones.
- Good luck! Happy porting 🎉

---

## 🙏 Credits

Special thanks to:                
- **@fahimfaisaladitto** - Gave the idea to make it more user-friendly
- **@NEESCHAL_3**        - Guided me in ROM knowledge
- **@PapaAlpha32**       - Started my ROM porting journey
- **as well as other Friends and contributors** who guided me on ROM knowledge and development.          