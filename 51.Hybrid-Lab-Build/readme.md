# 51. Building a Hybrid Attack Lab: Red vs Blue Team Setup in Azure + Hyper-V Part 1

- 🧪 Lab Introduction & Purpose: The video introduces a hybrid lab setup intended for red team attack simulations to identify gaps in security defenses across a tenant setup.

- 💻 Virtual Machines Setup: Three main VMs—domain controller, app server, and a client—are created locally using Hyper-V, all integrated with Azure Arc and equipped with Defender tools.

- 🌐 Azure Architecture Overview: Three Azure subscriptions are used: a hub for shared services, a "lab blue" for blue team elements, and a red team segment including MITRE Caldera and Kali Linux.

- 🛡️ Security Tools Configuration: Emphasis on using Defender for Cloud, Defender for Endpoint, and Defender for Identity, with plans to automate security configurations as much as possible.

- 🔐 Network Design: A hub-and-spoke model is implemented with VPN gateway access from local machines—no public IPs are used, maintaining traffic inside Azure.

### YouTube Video ###
https://youtu.be/vKZbetXS1Tw

### My Socials ###
BlueSky - https://bsky.app/profile/cyberautomate.bsky.social<br/>
LinkedIn - https://linkedin.com/in/david-hall10 <br/>
Github - https://github.com/cyberautomate