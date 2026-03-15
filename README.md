# 🚀 System & GPU Optimizer: Extreme Edition
**Created by Trigger911** | **Version: 03-15-2026**

This is my personal "one-click" solution to stop Windows from over-managing hardware. It targets system latency, bloatware, and hardware power-states to ensure your PC stays **on** and stays **fast**. 

**Optimized for all Windows 10/11 Desktop and Gaming PCs.**

---

## **🔥 Key Features**
*   **HPET Killer:** Disables the High Precision Event Timer via BCDEDIT **and** Device Manager to eliminate micro-stutters and input lag.
*   **Extended Bloatware Purge:** Removes 20+ junk apps including Xbox, Spotify, Teams, and Copilot.
*   **Extreme Latency Tweaks:** Hard-disables **VBS (Virtualization-Based Security)** and **Core Isolation**, freeing up CPU overhead for significantly higher FPS.
*   **Zero USB Disconnects:** Prevents Windows from putting USB Hubs and controllers to sleep (perfect for Sim-Racers and peripherals).
*   **Optional "Just the Browser" Tweak:** Interactive choice to strip down Chrome, Edge, and Firefox to bare essentials for privacy and speed.
*   **Smart RAM Management:** Detects 16GB+ RAM to disable memory compression and optimize system service splitting.

---

## **🚀 How to Use**

1.  **Download** `System Tweaks.bat` and the `chrisdeblot Powershell-5-25-2025.json` file.
2.  **Right-click** `System Tweaks.bat` and select **Run as Administrator**.
3.  Follow the **12 automated steps**.

### **⚙️ Importing the Chris Titus Preset**
When the blue **Chris Titus Windows Utility** window appears during Step 2:
1.  Click on the **"Tweaks"** tab at the top.
2.  Look for the **"Import"** button at the bottom of the window.
3.  Select the `chrisdeblot Powershell-5-25-2025.json` file.
4.  Click **"Run Tweaks"** to apply my custom high-performance configuration.

### **🛡️ O&O ShutUp10++ Instructions**
If you choose to run the O&O ShutUp tool within the utility:
*   **Recommended:** Select "Apply only recommended settings" (green checkmarks).
*   **⚠️ WARNING:** Avoid disabling **Location Services** if you use the Windows Weather widget or want automatic Time Zone updates. Disabling this can cause the system to "lose" your current location, resulting in broken weather data and incorrect system clocks.

---

## **🎮 NVIDIA Driver Optimization**
For NVIDIA users, I’ve included `New_TriggersNvidiaProfile.txt`. 

**How to Apply:**
1. Open **NVIDIA Profile Inspector**.
2. Click **Import Profiles** (Green arrow icon).
3. Select the file and click **Apply Changes**.

**⚠️ Hardware Optimization Advice:**
*   **RTX 30xx / 40xx / 50xx Series:** My profile is pre-configured for the **M Model Transformer** (best for Ampere, Ada Lovelace, and newer).
*   **GTX 10xx / 16xx / RTX 20xx Series:** If you are on an older GPU, manually switch the Transformer setting to **K Model** within the Inspector for better frame pacing and stability.

---

## **🤝 Credits & Acknowledgments**
*   **[Chris Titus Tech](https://christitus.com):** Windows Utility integration.
*   **[Corbin Davenport](https://github.com):** "Just the Browser" privacy tool.

---

## **📜 License**
This project is licensed under the **MIT License**.
