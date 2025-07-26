# Rosemary-Porter

Hi there! I'm **Arsham**, and welcome to **Rosemary-Porter** — a toolset for unpacking, modifying, and rebuilding ROMs easily using **UKL** and **Pyro** scripts.

This guide will walk you through setting everything up and using the tool effectively.

---

## 🚀 Getting Started

### 1. Clone the Repository

Open a terminal and run:

```bash
cd $HOME && git clone https://github.com/ArshamEbr/Rosemary-Porter.git && cd Rosemary-Porter
```

### 2. Add the UKL Tool

Unzip your `UKL.zip` **under the same directory** using `unzip UKL.zip`, so the structure looks like:

```
Rosemary-Porter/
├── UKL/
├── Pyro.sh
├── ...
```

---

## 🛠 ROM Extraction Guide (UKL)

### Step 1: Launch UKL

```bash
sudo UKL/run.sh
```

### Step 2: Extracting ROM Files

#### For Standard ROMs also known as `Fastboot ROMs`:

1. From the UKL menu, choose `3` → **Unpack .img**
2. Then choose `7` → **Enter image folder path .img**, and input the path to the folder where you've extracted your ROM ZIP with `cd /full/path/to/folder`.
3. You'll be prompted to extract a file — usually `super.img`. Choose it.

#### For `payload.bin` Based ROMs also known as `Recovery ROMs`:

1. From the menu, choose `11` → **Other Tools**
2. Then choose `6` → **Extracting images from payload.bin** and enter the path to the ROM folder.
3. After extraction:
   - Open a file manager as root, for example. run `sudo thunar` or any file manager.
   - Move the following files from `UKL/UnpackerPayload/` to `UKL/UnpackerSuper/`:
     - `system.img`
     - `system_ext.img`
     - `product.img`
     - `mi_ext.img`
     - `vendor.img` (**Use your device's `vendor.img` only!**)
   - Optionally, rename the images by appending `_a`:
     - e.g., `system.img` → `system_a.img`

---

### Step 3: Extract System Partitions

1. From the main menu again, select `3` → **Unpack .img**
2. Then select `2` → **Unpacking .img from folder: UKL/UnpackerSuper**
3. Select all images when prompted.

---

### Step 4: Exit UKL

From the main menu, choose:

```
14 → Exit
```

---

## 🔥 Running Pyro

Now run the Pyro script to patch and rebuild:

```bash
sudo Pyro.sh
```

Choose:

```
A → Run all steps automatically
```

If everything completes successfully, your modified ROM will be available in the `output` folder.

---

## 🎯 Final Notes

- Make sure you have basic familiarity with Linux & UKA/UKL tools.
- Use only your device's `vendor.img` to avoid compatibility issues.
- Vendor patching isn't implemented yet — for now, just use the vendor from a previously ported ROM.
- Open the `Pyro.sh` script and modify it to your heart's content, everything is explained with comments.
- Run all scripts with `sudo` to ensure correct permissions.
- Good luck! Happy porting 🎉

---

## 🙏 Credits

Special thanks to:
- **Friends and contributors** who guided me on ROM knowledge and development.