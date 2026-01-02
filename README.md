🚀 Multi-Panel & Addons Installer (2026)
Yeh ek automated Bash script hai jo Pterodactyl, Wings, Convoy, aur Blueprint Framework ke installation ko asaan banati hai. Is script se aap kuch hi clicks mein game servers aur VPS management panel setup kar sakte hain.
📋 Features
 * Pterodactyl Panel: Pura game server management interface.
 * Pterodactyl Wings: Server nodes install karne ka fast tarika.
 * Convoy Panel: KVM/VM (Virtual Machines) host karne ke liye setup.
 * Blueprint Framework: Addons aur themes install karne ka engine.
 * Addons Support: Player Manager, Nebula Theme, Subdomain Manager, etc.
🚀 Quick Start (Installation)
Apne server terminal par niche diye gaye commands ko run karein:

📖 Menu Guide
| Option | Name | Description |
|---|---|---|
| 1 | Pterodactyl Panel | Web dashboard install karne ke liye (Sabse pehle ye karein). |
| 2 | Pterodactyl Wings | Node setup karne ke liye (Jahan game server chalenge). |
| 3 | Convoy Panel | KVM-based VPS management panel install karne ke liye. |
| 4 | Blueprint Framework | Zaroori: Addons install karne ke liye ye framework chahiye. |
| 5 | Addons Menu | Nebula Theme, Player Manager aur baki cheezein yahan se install hongi. |
⚠️ Important Instructions
 * Fresh OS: Hamesha Ubuntu 22.04 ya 24.04 ka fresh installation use karein.
 * Addons Note: Koi bhi addon install karne se pehle Option 4 (Blueprint) ka install hona lazmi hai.
 * Backup: Addon install karne se pehle apni /var/www/pterodactyl directory ka backup zaroor lein, kyunki addons files ko modify karte hain.
 * Database: Convoy install karne ke baad /var/www/convoy/.env mein apni DB details bharna na bhulein.
🛠️ Requirements
 * RAM: Kam se kam 2GB (Agar dono panel ek saath chala rahe hain).
 * Virtualization: KVM support (Convoy ke liye zaroori hai).
 * Internet: Stable connection dependencies download karne ke liye.
Kya aap chahte hain ki main script mein "Self-Update" feature add karun jo naye addons auto-detect kar sake?
```bash <(curl -s https://raw.githubusercontent.com/shadowplayzz44-max/Allpanel/main/All.sh)
