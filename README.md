# 🚀 System & GPU Optimizer
**Created by Trigger911** | **Version: 03-15-2026**

This is my personal "one-click" solution to stop Windows from over-managing hardware. It targets system latency, bloatware, and hardware power-states to ensure your PC stays **on** and stays **fast**. 

**Optimized for high-end Windows 10/11 Desktop and Gaming PCs.**

---

## **🔥 Key Features**
*   **HPET Killer:** Disables the High Precision Event Timer via BCDEDIT **and** Device Manager to eliminate micro-stutters and input lag.
*   **96GB+ Smart RAM Management:** Automatically detects high-capacity RAM (optimized for 96GB/128GB builds) to disable memory compression and set the `SvcHostSplitThreshold` to match your hardware overhead.
*   **Extended Bloatware Purge:** Removes 20+ junk apps including Xbox, Spotify, Teams, and Copilot.
*   **Extreme Latency Tweaks:** Hard-disables **VBS (Virtualization-Based Security)** and **Core Isolation**, freeing up CPU overhead for significantly higher FPS.
*   **Zero USB Disconnects:** Prevents Windows from putting USB Hubs and controllers to sleep (perfect for Sim-Racers and peripherals).
*   **Automated Logging:** Every tweak is recorded to `Optimizer_Log.txt` for easy troubleshooting.

---

## **🚀 How to Use**

1.  **Download** `System Tweaks.bat` and the `chrisdeblot Powershell-5-25-2025.json` file.
2.  **Right-click** `System Tweaks.bat` and select **Run as Administrator**.
3.  Follow the **16 automated steps**.

### **⚙️ Importing the Chris Titus Preset**
When the blue **Chris Titus Windows Utility** window appears during Step 2:
1.  Click on the **"Tweaks"** tab at the top.
2.  Click the **"Import"** button at the bottom.
3.  Select the `chrisdeblot Powershell-5-25-2025.json` file.
4.  Click **"Run Tweaks"** to apply the custom high-performance configuration.

---

## **🎮 NVIDIA Driver Optimization**
For NVIDIA users, I’ve included `New_TriggersNvidiaProfile.txt`. 

**How to Apply:**
1. Open **NVIDIA Profile Inspector**.
2. Click **Import Profiles** (Green arrow icon).
3. Select the file and click **Apply Changes**.

**⚠️ Hardware Optimization Advice:**
*   **RTX 30xx / 40xx / 50xx Series:** Profile is pre-configured for the **M Model Transformer** (Best for Ampere/Ada).
*   **GTX 10xx / 16xx / RTX 20xx Series:** Manually switch the Transformer setting to **K Model** within the Inspector for better frame pacing.

---

## **🔄 How to Undo Changes**

While the script creates a **System Restore Point** at the start, here is how to manually revert specific changes:

### **1. For the "System Tweaks.bat" Script**
Run the **`Restore_Defaults.bat`** file that was generated in your folder during the optimization process. 
*   **What it does:** Re-enables VBS, Hypervisor, and Hibernation, and sets your Power Plan back to "Balanced."

### **2. For the Chris Titus Windows Utility**
To undo tweaks made within the Titus tool:
1.  Relaunch the tool (Step 2 in the script).
2.  Go to the **"Tweaks"** tab.
3.  Look for the **"Undo Tweaks"** or **"Default"** buttons on the right-hand side to revert service and registry changes.

### **3. For "Just the Browser"**
Because this tool modifies the internal files of your browsers to strip them down:
1.  **Uninstall** the affected browser (Chrome, Edge, or Firefox).
2.  **Download and Reinstall** a fresh copy from the official website. This will overwrite the optimized files with standard ones.

---

## **🤝 Credits & Acknowledgments**
*   **[Chris Titus Tech](https://christitus.com):** Windows Utility integration.
*   **[Corbin Davenport](https://github.com):** "Just the Browser" privacy tool concepts.
*   **[Trigger911](https://github.com):** Project lead and 96GB RAM optimization logic.

---

## **📜 License**
This project is licensed under the **MIT License**.
