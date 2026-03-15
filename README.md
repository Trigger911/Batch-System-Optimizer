# System & GPU Optimizer
**Created by Trigger911**

I got tired of Windows turning off my USB ports, messing with my network stability, and introducing micro-stuttering during gaming. This script is my personal "one-click" solution to stop Windows from over-managing my hardware. It’s designed specifically for power users, simmers, and gamers who want their hardware to stay **on** and stay **fast**.

---

## **What it actually does**
*   **No more USB disconnects:** Force-disables "Power Management" across all USB Hubs and Host Controllers (like those annoying AMD eXtensible controllers). If it's a USB port, Windows is no longer allowed to put it to sleep.
*   **Solid Network Stack:** Resets your winsock and kills "Energy Efficient Ethernet" so your connection doesn't drop to save a few milliwatts.
*   **Timing & Input Fixes:** Tweaks BCDEDIT for better timer resolution and tightens up mouse/keyboard data queues for the most responsive feel possible.
*   **Smart RAM Management:** Automatically detects if you have 16GB+ of RAM and disables memory compression to prioritize raw speed over space-saving.
*   **Safety First:** Automatically generates a system restore point named **"System Optimizer [Date]"** before it touches a single setting, so you can always roll back.

---

## **How to Use**
1.  **Download** the `optimizer.bat` file from this repository.
2.  **Right-click** the file and select **Run as Administrator**.
3.  The script will guide you through 8 optimization steps.
4.  **Restart your computer** once the script finishes to apply all changes.

---

## **Credits & Acknowledgments**
This script integrates the incredible [Windows Utility](https://christitus.com) created by **Chris Titus Tech**. 
*   **Official Site:** [ChrisTitus.com](https://christitus.com)
*   **GitHub Repository:** [ChrisTitusTech/winutil](https://github.com)

---

## **License**
This project is licensed under the **MIT License**.
